export const meta = {
  name: 'audit-routes',
  description: 'Find every API route and audit each one for auth and input validation',
  phases: [{ title: 'Discover' }, { title: 'Audit' }],
}

const routes = await agent(
  'List every HTTP API route in this repo. Return file path and method+path for each.',
  {
    label: 'discover', phase: 'Discover',
    schema: { type: 'object', properties: { routes: { type: 'array', items: { type: 'object',
      properties: { file: { type: 'string' }, route: { type: 'string' } }, required: ['file', 'route'] } } },
      required: ['routes'] },
  },
)

const results = await parallel(routes.routes.map(r => () =>
  agent(`Audit route ${r.route} in ${r.file}: is it authenticated, authorized, and is input validated? Be concise.`,
    { label: `audit:${r.route}`, phase: 'Audit' })
))

return { routes: routes.routes, results }
