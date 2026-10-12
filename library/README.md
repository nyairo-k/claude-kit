# Library index

What's in the library, what each item does, and how to put it into a project.
Every item was fetched with `bin/fetch.sh`; sources and dates are in [CATALOGUE.md](CATALOGUE.md).

To use items in a project:

    bin/new-project.sh ~/my-app skills/gsap-core skills/web-typography rules/html-css-style-color-guide.md

## UI design kit (added 2026-10-12)

### Design quality and layout
| Item | What it does | Source |
|---|---|---|
| `skills/web-design-guidelines` | Reviews your UI code against Vercel's Web Interface Guidelines: layout, spacing, accessibility, responsiveness. Trigger: "review my UI", "audit design". | Vercel (official), 725K installs |
| `skills/high-end-visual-design` | Makes Claude design like a high-end agency: exact fonts, spacing, shadows, card structures, animations. Blocks the generic defaults that make AI designs look cheap. | leonxlnx/taste-skill, 431K |
| `skills/build-awwwards-quality-sites` | Art-directs and builds Awwwards-style marketing, editorial, portfolio and landing sites: standout heroes, GSAP choreography, smooth scroll, optional Three.js. | Meng To (Design+Code) |
| `skills/better-ui` | Polishes surfaces, icons and motion with exact values: border radius, optical alignment, shadows, icon states. | jakubkrehel/skills |
| `skills/impeccable` ⚠️ | A design, critique and polish **tool**, not only a guide. Downloads its own CLI, can install a per-edit design-detector hook (asks consent), has a live browser overlay. Heavy (2.3 MB). Drop it if you want guides only. | Paul Bakaus, 326K |
| `rules/html-css-style-color-guide.md` | Always-on rules for colour usage and HTML/CSS styling, applied to `.html`, `.css`, `.js` files. | awesome-copilot |

### Typography
| Item | What it does | Source |
|---|---|---|
| `skills/web-typography` | Selects, pairs and implements typefaces: font pairing, type hierarchy, typographic scale, line height, responsive type, variable fonts, font loading (FOUT/FOIT). | wondelai/skills |

### Motion principles
| Item | What it does | Source |
|---|---|---|
| `skills/design-motion-principles` | Motion and interaction design based on Emil Kowalski, Jakub Krehel and Jhey Tompkins. Two modes: build components with purposeful motion, or audit existing animations for "AI-slop" patterns. | kylezantos |
| `skills/animation-vocabulary` | Reverse glossary: describe an effect vaguely ("the bouncy thing when a popover opens") and get its exact name, so you can ask for it precisely. | Emil Kowalski, 205K |

### GSAP
| Item | What it does | Source |
|---|---|---|
| `skills/gsap-core` | Core GSAP API: `gsap.to/from/fromTo`, easing, stagger, defaults, `matchMedia` (responsive and reduced-motion). | GreenSock (official) |
| `skills/gsap-scrolltrigger` | Scroll-linked animation: ScrollTrigger, pinning, scrub, parallax, triggers. | GreenSock (official) |
| `skills/gsap-timeline` | Sequencing and choreography: `gsap.timeline()`, position parameter, nesting, playback control. | GreenSock (official) |
| `skills/cinematic-gsap-lenis-motion-system` | Premium cinematic motion systems with GSAP + ScrollTrigger + Lenis smooth scroll: reveals, staggered text, parallax, pinned sections, magnetic hovers. | Meng To |

GreenSock also publishes `gsap-react`, `gsap-plugins`, `gsap-performance`, `gsap-utils` and `gsap-frameworks`: `bin/fetch.sh skill greensock/gsap-skills@gsap-react`.

### Framer Motion and components
| Item | What it does | Source |
|---|---|---|
| `skills/framer-motion-animator` | Framer Motion animations and micro-interactions: page transitions, gestures, scroll-based animation, orchestrated sequences. | patricio0312rev/skills |
| `skills/animated-component-libraries` | Ready-made animated React components from Magic UI (150+) and React Bits (90+) for landing pages, dashboards, marketing sites. | freshtechbro |
| `skills/expo-native-ui` | Native-feeling Expo/React Native screens: Apple HIG, semantic colours, SF Symbols, gradients, responsive layout. | Expo (official) |

### Plugins
| Item | What it does |
|---|---|
| `plugins/frontend-design@claude-plugins-official` | Anthropic's frontend-design skill (977K installs): distinctive, production-grade interfaces. Installed by `new-project.sh`, not copied. |

## Other
| Item | What it does |
|---|---|
| `skills/wrangler` | Cloudflare Wrangler CLI: Workers local dev, previews, deployment, resources. (Cloudflare, official) |
| `skills/codeql` | CodeQL code scanning via GitHub Actions and the CLI. |
| `agents/code-reviewer.md` | Reviews a diff for bugs, missing tests, unclear code. |
| `agents/security-auditor.md` | Audits code for injection, auth flaws, secrets. |
| `agents/se-ux-ui-designer.md` | UX research artefacts: jobs-to-be-done, user journeys. |
| `hooks/validate-bash.sh` | Blocks dangerous shell commands (force push, `rm -rf /`, …). Already registered in the template. |
| `workflows/audit-routes.js` | Finds every API route and audits each for auth and validation. |

## A sensible starter set for a web UI project

    bin/new-project.sh ~/my-site \
      skills/web-design-guidelines skills/high-end-visual-design skills/web-typography \
      skills/design-motion-principles skills/gsap-core skills/gsap-scrolltrigger skills/gsap-timeline \
      rules/html-css-style-color-guide.md plugins/frontend-design@claude-plugins-official

Add `skills/framer-motion-animator` for React/Next projects, `skills/cinematic-gsap-lenis-motion-system` and
`skills/build-awwwards-quality-sites` for showcase sites. Don't load everything into one project: each skill's
description is read at the start of every session, and overlapping design skills can pull in different directions.
