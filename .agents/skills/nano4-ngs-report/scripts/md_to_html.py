#!/usr/bin/env python3
"""
Zero-Dependency Standalone Markdown to HTML/PDF Report Compiler
Part of the `nano4-ngs-report` Agent Skill.
Uses ONLY Python 3 standard library modules.
Supports:
- Automatic Table of Contents (TOC)
- GitHub-flavored Markdown tables
- GitHub Alerts ([!NOTE], [!TIP], [!IMPORTANT], [!WARNING], [!CAUTION])
- Mermaid.js diagrams (```mermaid)
- Code blocks & inline formatting
- Print-to-PDF (@media print) optimization
"""

import argparse
import datetime
import html
import os
import re
import sys
from pathlib import Path


ALERT_META = {
    "NOTE": ("ℹ️ Note / 說明", "alert-note"),
    "TIP": ("💡 Tip / 實戰技巧", "alert-tip"),
    "IMPORTANT": ("📌 Important / 重要關鍵", "alert-important"),
    "WARNING": ("⚠️ Warning / 注意事項", "alert-warning"),
    "CAUTION": ("🚨 Caution / 警戒鐵律", "alert-caution"),
}


def slugify(text: str) -> str:
    clean = re.sub(r"<[^>]+>", "", text)
    clean = re.sub(r"[^\w\s\u4e00-\u9fff-]", "", clean).strip().lower()
    clean = re.sub(r"[\s]+", "-", clean)
    return clean or "section"


def format_inline(text: str) -> str:
    # Protect inline code first
    code_spans = []

    def save_code(match):
        idx = len(code_spans)
        code_spans.append(f"<code>{html.escape(match.group(1))}</code>")
        return f"\x00CODE{idx}\x00"

    text = re.sub(r"`([^`]+)`", save_code, text)

    # Escape HTML in remaining text
    text = html.escape(text)

    # Replace common LaTeX inline symbols with clean Unicode
    latex_replacements = {
        r"\rightarrow": "→",
        r"\leftarrow": "←",
        r"\leftrightarrow": "↔",
        r"\Rightarrow": "⇒",
        r"\pm": "±",
        r"\sigma": "σ",
        r"\ge": "≥",
        r"\le": "≤",
        r"\times": "×",
    }
    for k, v in latex_replacements.items():
        text = text.replace(k, v)
    text = re.sub(r"\$([^$]+)\$", r"<span class='math'>\1</span>", text)

    # Links: [label](url)
    def replace_link(m):
        label = m.group(1)
        url = m.group(2)
        return f'<a href="{url}" target="_blank" rel="noopener">{label}</a>'

    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", replace_link, text)

    # Bold & Italic
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"\*([^*]+)\*", r"<em>\1</em>", text)

    # Restore inline code
    for idx, span in enumerate(code_spans):
        text = text.replace(f"\x00CODE{idx}\x00", span)

    return text


def parse_markdown(md_text: str):
    lines = md_text.splitlines()
    # Strip optional YAML frontmatter
    if lines and lines[0].strip() == "---":
        for idx in range(1, len(lines)):
            if lines[idx].strip() == "---":
                lines = lines[idx + 1 :]
                break

    html_out = []
    toc = []
    used_ids = {}

    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]
        stripped = line.strip()

        # Blank line
        if not stripped:
            i += 1
            continue

        # Horizontal Rule
        if re.match(r"^(\*{3,}|-{3,}|_{3,})$", stripped):
            html_out.append("<hr>")
            i += 1
            continue

        # Fenced Code Block
        if stripped.startswith("```"):
            lang = stripped[3:].strip().lower()
            code_lines = []
            i += 1
            while i < n and not lines[i].strip().startswith("```"):
                code_lines.append(lines[i])
                i += 1
            i += 1  # skip closing ```
            code_content = "\n".join(code_lines)
            if lang == "mermaid":
                html_out.append(
                    f'<div class="mermaid-container"><pre class="mermaid">{html.escape(code_content)}</pre></div>'
                )
            else:
                lang_badge = f'<div class="code-lang">{html.escape(lang)}</div>' if lang else ""
                html_out.append(
                    f'<div class="code-block">{lang_badge}<pre><code>{html.escape(code_content)}</code></pre></div>'
                )
            continue

        # Headings
        m_head = re.match(r"^(#{1,6})\s+(.*)$", stripped)
        if m_head:
            level = len(m_head.group(1))
            raw_title = m_head.group(2).strip()
            formatted_title = format_inline(raw_title)
            base_id = slugify(raw_title)
            count = used_ids.get(base_id, 0)
            used_ids[base_id] = count + 1
            sec_id = f"{base_id}-{count}" if count > 0 else base_id

            if level in (1, 2, 3):
                toc.append((level, sec_id, re.sub(r"<[^>]+>", "", formatted_title)))
            html_out.append(f'<h{level} id="{sec_id}">{formatted_title}</h{level}>')
            i += 1
            continue

        # Blockquote or GitHub Alert
        if stripped.startswith(">"):
            quote_lines = []
            while i < n and lines[i].strip().startswith(">"):
                content = re.sub(r"^>\s?", "", lines[i].strip())
                quote_lines.append(content)
                i += 1

            first_line = quote_lines[0].strip() if quote_lines else ""
            m_alert = re.match(r"^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*(.*)$", first_line, re.I)
            if m_alert:
                alert_type = m_alert.group(1).upper()
                inline_rest = m_alert.group(2).strip()
                title_label, css_cls = ALERT_META.get(alert_type, ("Note", "alert-note"))
                body_lines = []
                if inline_rest:
                    body_lines.append(format_inline(inline_rest))
                for ql in quote_lines[1:]:
                    if ql.strip():
                        body_lines.append(format_inline(ql.strip()))
                body_html = "<br>".join(body_lines)
                html_out.append(
                    f'<div class="alert {css_cls}"><div class="alert-title">{title_label}</div><div class="alert-body">{body_html}</div></div>'
                )
            else:
                body_html = "<br>".join(format_inline(ql) for ql in quote_lines if ql.strip())
                html_out.append(f"<blockquote>{body_html}</blockquote>")
            continue

        # Markdown Table
        if "|" in stripped and i + 1 < n and re.match(r"^\|?[\s:|-]+\|[\s:|-]*$", lines[i + 1].strip()):
            header_cells = [c.strip() for c in stripped.strip("|").split("|")]
            align_cells = [c.strip() for c in lines[i + 1].strip().strip("|").split("|")]
            alignments = []
            for ac in align_cells:
                if ac.startswith(":") and ac.endswith(":"):
                    alignments.append("center")
                elif ac.endswith(":"):
                    alignments.append("right")
                else:
                    alignments.append("left")

            i += 2
            rows = []
            while i < n and "|" in lines[i].strip() and lines[i].strip():
                row_cells = [c.strip() for c in lines[i].strip().strip("|").split("|")]
                rows.append(row_cells)
                i += 1

            table_html = ['<div class="table-wrapper"><table><thead><tr>']
            for idx, hc in enumerate(header_cells):
                align = alignments[idx] if idx < len(alignments) else "left"
                table_html.append(f'<th style="text-align:{align}">{format_inline(hc)}</th>')
            table_html.append("</tr></thead><tbody>")
            for r in rows:
                table_html.append("<tr>")
                for idx, cell in enumerate(r):
                    align = alignments[idx] if idx < len(alignments) else "left"
                    table_html.append(f'<td style="text-align:{align}">{format_inline(cell)}</td>')
                table_html.append("</tr>")
            table_html.append("</tbody></table></div>")
            html_out.append("".join(table_html))
            continue

        # Lists (Unordered or Ordered)
        m_ul = re.match(r"^(\s*)([-*+])\s+(.*)$", line)
        m_ol = re.match(r"^(\s*)(\d+\.)\s+(.*)$", line)
        if m_ul or m_ol:
            list_items = []
            is_ordered = bool(m_ol)
            tag = "ol" if is_ordered else "ul"
            while i < n:
                cur = lines[i]
                if not cur.strip():
                    break
                m_u = re.match(r"^(\s*)([-*+])\s+(.*)$", cur)
                m_o = re.match(r"^(\s*)(\d+\.)\s+(.*)$", cur)
                if m_u or m_o:
                    m_cur = m_u or m_o
                    indent = len(m_cur.group(1))
                    item_text = format_inline(m_cur.group(3).strip())
                    sub_cls = ' class="sub-item"' if indent >= 2 else ""
                    list_items.append(f"<li{sub_cls}>{item_text}</li>")
                    i += 1
                elif cur.startswith("  ") and list_items:
                    list_items[-1] = list_items[-1][:-5] + "<br>" + format_inline(cur.strip()) + "</li>"
                    i += 1
                else:
                    break
            html_out.append(f"<{tag}>" + "".join(list_items) + f"</{tag}>")
            continue

        # Normal Paragraph
        para_lines = []
        while i < n:
            cur_s = lines[i].strip()
            if (
                not cur_s
                or cur_s.startswith("#")
                or cur_s.startswith("```")
                or cur_s.startswith(">")
                or re.match(r"^(\*{3,}|-{3,}|_{3,})$", cur_s)
                or re.match(r"^(\s*)([-*+]|\d+\.)\s+", lines[i])
                or ("|" in cur_s and i + 1 < n and re.match(r"^\|?[\s:|-]+\|[\s:|-]*$", lines[i + 1].strip()))
            ):
                break
            para_lines.append(format_inline(cur_s))
            i += 1
        if para_lines:
            html_out.append("<p>" + " ".join(para_lines) + "</p>")

    return "\n".join(html_out), toc


HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="zh-Hant">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title}</title>
<style>
  :root {{
    --bg: #f8fafc;
    --surface: #ffffff;
    --text: #1e293b;
    --muted: #64748b;
    --primary: #0f4c81;
    --accent: #0284c7;
    --border: #e2e8f0;
    --code-bg: #0f172a;
    --code-text: #f1f5f9;
  }}
  * {{ box-sizing: border-box; }}
  body {{
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans TC", "Microsoft JhengHei", sans-serif;
    background: var(--bg);
    color: var(--text);
    line-height: 1.7;
  }}
  .top-bar {{
    position: sticky;
    top: 0;
    z-index: 100;
    background: var(--primary);
    color: #fff;
    padding: 0.75rem 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 2px 8px rgba(0,0,0,0.12);
  }}
  .top-bar-title {{
    font-weight: 700;
    font-size: 1.05rem;
    letter-spacing: 0.02em;
  }}
  .print-btn {{
    background: #ffffff;
    color: var(--primary);
    border: none;
    padding: 0.45rem 1rem;
    border-radius: 6px;
    font-weight: 600;
    cursor: pointer;
    font-size: 0.9rem;
    transition: background 0.15s;
  }}
  .print-btn:hover {{ background: #e0f2fe; }}
  .layout {{
    max-width: 1320px;
    margin: 2rem auto;
    padding: 0 1.5rem;
    display: grid;
    grid-template-columns: 280px 1fr;
    gap: 2rem;
    align-items: start;
  }}
  .toc-sidebar {{
    position: sticky;
    top: 4.5rem;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 1.25rem;
    max-height: calc(100vh - 6rem);
    overflow-y: auto;
    box-shadow: 0 1px 3px rgba(0,0,0,0.04);
  }}
  .toc-header {{
    font-weight: 700;
    font-size: 0.95rem;
    color: var(--primary);
    margin-bottom: 0.75rem;
    padding-bottom: 0.5rem;
    border-bottom: 2px solid var(--border);
  }}
  .toc-list {{
    list-style: none;
    padding: 0;
    margin: 0;
    font-size: 0.875rem;
  }}
  .toc-list li {{ margin: 0.35rem 0; }}
  .toc-lvl-2 {{ padding-left: 0.5rem; font-weight: 600; }}
  .toc-lvl-3 {{ padding-left: 1.35rem; color: var(--muted); }}
  .toc-list a {{
    color: inherit;
    text-decoration: none;
    display: block;
    padding: 0.15rem 0.35rem;
    border-radius: 4px;
  }}
  .toc-list a:hover {{
    background: #f1f5f9;
    color: var(--accent);
  }}
  .report-card {{
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 2.75rem 3.25rem;
    box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04);
    min-width: 0;
  }}
  h1 {{
    font-size: 2rem;
    color: var(--primary);
    margin-top: 0;
    padding-bottom: 0.75rem;
    border-bottom: 3px solid var(--primary);
  }}
  h2 {{
    font-size: 1.45rem;
    color: var(--primary);
    margin-top: 2.25rem;
    padding-bottom: 0.4rem;
    border-bottom: 1px solid var(--border);
  }}
  h3 {{
    font-size: 1.18rem;
    color: #1e3a8a;
    margin-top: 1.6rem;
  }}
  h4 {{
    font-size: 1.02rem;
    color: #334155;
    margin-top: 1.2rem;
  }}
  p {{ margin: 0.85rem 0; }}
  a {{ color: var(--accent); text-decoration: none; }}
  a:hover {{ text-decoration: underline; }}
  hr {{
    border: none;
    border-top: 1px solid var(--border);
    margin: 2rem 0;
  }}
  code {{
    font-family: "JetBrains Mono", "Fira Code", Consolas, monospace;
    background: #f1f5f9;
    color: #be123c;
    padding: 0.15rem 0.4rem;
    border-radius: 4px;
    font-size: 0.88em;
  }}
  .code-block {{
    position: relative;
    margin: 1.1rem 0;
    border-radius: 8px;
    overflow: hidden;
    background: var(--code-bg);
  }}
  .code-lang {{
    background: #1e293b;
    color: #94a3b8;
    font-size: 0.75rem;
    font-family: monospace;
    padding: 0.3rem 0.85rem;
    text-transform: uppercase;
    border-bottom: 1px solid #334155;
  }}
  .code-block pre {{
    margin: 0;
    padding: 1rem 1.25rem;
    overflow-x: auto;
  }}
  .code-block code {{
    background: transparent;
    color: var(--code-text);
    padding: 0;
    font-size: 0.875rem;
    line-height: 1.55;
  }}
  .table-wrapper {{
    overflow-x: auto;
    margin: 1.25rem 0;
  }}
  table {{
    width: 100%;
    border-collapse: collapse;
    font-size: 0.92rem;
  }}
  th, td {{
    border: 1px solid var(--border);
    padding: 0.65rem 0.9rem;
  }}
  th {{
    background: #f1f5f9;
    color: var(--primary);
    font-weight: 700;
  }}
  tr:nth-child(even) td {{ background: #f8fafc; }}
  ul, ol {{ padding-left: 1.5rem; margin: 0.75rem 0; }}
  li {{ margin: 0.35rem 0; }}
  li.sub-item {{ margin-left: 1.25rem; list-style-type: circle; }}
  blockquote {{
    margin: 1rem 0;
    padding: 0.75rem 1.25rem;
    border-left: 4px solid var(--accent);
    background: #f8fafc;
    color: #334155;
    border-radius: 0 6px 6px 0;
  }}
  .alert {{
    margin: 1.25rem 0;
    padding: 1rem 1.25rem;
    border-radius: 8px;
    border-left: 5px solid;
  }}
  .alert-title {{
    font-weight: 700;
    margin-bottom: 0.35rem;
    font-size: 0.95rem;
  }}
  .alert-note {{ background: #eff6ff; border-color: #3b82f6; color: #1e3a8a; }}
  .alert-tip {{ background: #f0fdf4; border-color: #22c55e; color: #14532d; }}
  .alert-important {{ background: #faf5ff; border-color: #a855f7; color: #581c87; }}
  .alert-warning {{ background: #fffbeb; border-color: #f59e0b; color: #78350f; }}
  .alert-caution {{ background: #fef2f2; border-color: #ef4444; color: #7f1d1d; }}
  .mermaid-container {{
    background: #ffffff;
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 1.25rem;
    margin: 1.25rem 0;
    text-align: center;
    overflow-x: auto;
  }}
  .report-footer {{
    margin-top: 3rem;
    padding-top: 1rem;
    border-top: 1px solid var(--border);
    font-size: 0.85rem;
    color: var(--muted);
    display: flex;
    justify-content: space-between;
  }}
  @media (max-width: 960px) {{
    .layout {{ grid-template-columns: 1fr; }}
    .toc-sidebar {{ position: static; max-height: none; }}
    .report-card {{ padding: 1.5rem; }}
  }}
  @media print {{
    body {{ background: #fff; }}
    .top-bar, .toc-sidebar {{ display: none !important; }}
    .layout {{ display: block; margin: 0; padding: 0; max-width: 100%; }}
    .report-card {{ border: none; box-shadow: none; padding: 0; }}
    pre, table, .alert, .mermaid-container {{ page-break-inside: avoid; }}
    h2, h3 {{ page-break-after: avoid; }}
  }}
</style>
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
  mermaid.initialize({{ startOnLoad: true, theme: 'default', securityLevel: 'loose' }});
</script>
</head>
<body>
  <div class="top-bar">
    <div class="top-bar-title">{title}</div>
    <button class="print-btn" onclick="window.print()">🖨️ 列印 / 另存為 PDF</button>
  </div>
  <div class="layout">
    <aside class="toc-sidebar">
      <div class="toc-header">📑 報告章節導覽</div>
      <ul class="toc-list">
        {toc_html}
      </ul>
    </aside>
    <main class="report-card">
      {body_html}
      <div class="report-footer">
        <span>Generated by <strong>nano4-ngs-report</strong> Skill</span>
        <span>Compiled at: {timestamp}</span>
      </div>
    </main>
  </div>
</body>
</html>
"""


def main():
    parser = argparse.ArgumentParser(description="Compile Markdown report to standalone HTML")
    parser.add_argument("input_md", help="Path to input Markdown (.md) file")
    parser.add_argument("output_html", help="Path to output HTML (.html) file")
    parser.add_argument("--title", default=None, help="Report title (defaults to first H1)")
    args = parser.parse_args()

    in_path = Path(args.input_md)
    out_path = Path(args.output_html)

    if not in_path.exists():
        print(f"[ERROR] Input file not found: {in_path}", file=sys.stderr)
        sys.exit(1)

    md_text = in_path.read_text(encoding="utf-8")
    body_html, toc = parse_markdown(md_text)

    title = args.title
    if not title:
        for lvl, _, text in toc:
            if lvl == 1:
                title = text
                break
    if not title:
        title = in_path.stem

    toc_items = []
    for lvl, sec_id, text in toc:
        toc_items.append(f'<li class="toc-lvl-{lvl}"><a href="#{sec_id}">{html.escape(text)}</a></li>')

    out_path.parent.mkdir(parents=True, exist_ok=True)
    final_html = HTML_TEMPLATE.format(
        title=html.escape(title),
        toc_html="\n        ".join(toc_items),
        body_html=body_html,
        timestamp=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    )
    out_path.write_text(final_html, encoding="utf-8")
    print(f"[OK] Standalone HTML report generated: {out_path} ({out_path.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
