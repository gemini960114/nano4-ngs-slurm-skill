// Generate docs/guide/*.md from the chapter READMEs, so each chapter has a
// single source of truth. Run automatically by `npm run docs:dev|docs:build`.
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..')
const REPO = 'https://github.com/gemini960114/nano4-ngs-slurm-skill'

const CHAPTERS = {
  '01-install-antigravity': '01_install_antigravity',
  '02-nano4-login-and-setup': '02_nano4_login_and_setup',
  '03-basic-slurm-and-qc': '03_basic_slurm_and_qc',
  '04-qiime2-microbiome-pipeline': '04_qiime2_microbiome_pipeline',
  '05-automated-report-skill': '05_automated_report_skill',
}

mkdirSync(join(ROOT, 'docs', 'guide'), { recursive: true })

function rewriteLinks(markdown, rewrite) {
  return markdown.replace(/\]\(([^)\s]+)\)/g, (match, target) => {
    const next = rewrite(target)
    return next === undefined ? match : `](${next})`
  })
}

function chapterPage(target, prefix) {
  const m = target.match(new RegExp(`^${prefix}(\\d\\d-[a-z0-9-]+)(?:/README\\.md|/)?(#.*)?$`))
  if (m && CHAPTERS[m[1]]) return `./${CHAPTERS[m[1]]}${m[2] ?? ''}`
  return undefined
}

function fromChapter(dir, target) {
  if (/^(https?:|mailto:|#)/.test(target)) return undefined
  if (target === '../AGENTS.md') return './agents_governance'
  if (target === '../Example.md') return './examples_all'
  if (target === '../README.md') return './00_overview'
  if (target.startsWith('../.agents/') || target.startsWith('../data/')) {
    const clean = target.slice(3)
    const kind = clean.endsWith('/') ? 'tree' : 'blob'
    return `${REPO}/${kind}/main/${clean.replace(/\/$/, '')}`
  }
  const page = chapterPage(target, '\\.\\./')
  if (page) return page
  if (target.startsWith('./')) {
    const path = target.slice(2)
    const kind = path.endsWith('/') || path === '' ? 'tree' : 'blob'
    return `${REPO}/${kind}/main/${dir}/${path.replace(/\/$/, '')}`
  }
  return undefined
}

function fromRoot(target) {
  if (/^(https?:|mailto:|#)/.test(target)) return undefined
  if (target === './AGENTS.md' || target === 'AGENTS.md') return './agents_governance'
  if (target === './Example.md' || target === 'Example.md') return './examples_all'
  const page = chapterPage(target, '(?:\\./)?')
  if (page) return page
  if (target.startsWith('./') || target.startsWith('.agents/') || target.startsWith('data/')) {
    const clean = target.replace(/^\.\//, '')
    const kind = clean.endsWith('/') ? 'tree' : 'blob'
    return `${REPO}/${kind}/main/${clean.replace(/\/$/, '')}`
  }
  return undefined
}

const write = (page, content) => {
  writeFileSync(join(ROOT, 'docs', 'guide', `${page}.md`), content)
  console.log(`synced docs/guide/${page}.md`)
}

for (const [dir, page] of Object.entries(CHAPTERS)) {
  const source = readFileSync(join(ROOT, dir, 'README.md'), 'utf8')
  write(page, rewriteLinks(source, (t) => fromChapter(dir, t)))
}

write('00_overview', rewriteLinks(readFileSync(join(ROOT, 'README.md'), 'utf8'), fromRoot))
write('examples_all', rewriteLinks(readFileSync(join(ROOT, 'Example.md'), 'utf8'), fromRoot))
write('agents_governance', readFileSync(join(ROOT, 'AGENTS.md'), 'utf8'))
