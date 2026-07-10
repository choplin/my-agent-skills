---
name: web-access
description: This skill should be used when reading, opening, or fetching the content of a web page or URL, to choose between the agent's plain web-fetch tool and a full browser session (for JavaScript-rendered content, sites needing an authenticated session, or bot-blocked pages), with a fallback when a plain fetch returns an empty body or JS shell. Triggers on "このページを見て", "URLの中身を読んで", "ログインが必要なサイトを参照して", "JSで描画されるページを読んで", "open this URL", "read this web page", "fetch this site". Should NOT trigger for keyword web search with no specific URL (use a web-search tool), or when a dedicated integration already covers the source (GitHub, Linear, Jira/Confluence, Google Drive).
user-invocable: true
---

# Web Access: plain fetch vs full browser

Reading a URL has two paths. A **plain fetch** — the agent's built-in web-fetch
tool — does a plain HTTP request: fast, cheap, no session, no JavaScript
execution. A **full browser** drives a real browser tab with the user's
logged-in cookies and a full JS runtime. Default to the plain fetch; escalate to
a full browser only when the page actually needs one. This skill is the decision
rule for that choice.

> **Tool mapping.** Each agent exposes these under its own names. Use whatever
> your host provides. Under Claude Code the plain fetch is the **WebFetch** tool
> and the full browser is **Claude in Chrome**. If the host has no plain-fetch
> tool at all, say so and stop rather than silently guessing at page content.

## Default: plain fetch

For a static, publicly-readable page — docs, blog posts, README-style pages,
most articles, API references, RFCs — use the plain fetch. It is the right tool
the majority of the time. Do not reach for a full browser just because a URL is
involved.

## Escalate to a full browser when

Pick a full browser up front (without trying a plain fetch first) when the page
clearly falls into one of these:

- **Requires a logged-in session.** Private dashboards and admin consoles (Grafana, Datadog, cloud provider consoles), internal tools behind SSO, paywalled or member-only content, a user's own account pages, SNS timelines/DMs. A plain fetch has no cookies, so it sees a login wall or nothing.
- **Content is rendered client-side by JavaScript.** SPAs where the initial HTML is an empty shell, content that only appears after scrolling/clicking, infinite-scroll feeds, pages whose data loads via XHR after paint. A plain fetch returns the pre-render HTML, which is often useless. Typical: X/Twitter, LinkedIn, Facebook, Instagram, Notion public pages, Figma, many React/Vue dashboards.
- **The site blocks plain fetches.** Bot walls, aggressive Cloudflare/anti-scraping, endpoints that 403/429 automated clients. A real browser session usually passes.
- **The task needs interaction.** Clicking through steps, filling a form, navigating a multi-page flow, reading a page reached only after in-page actions. A plain fetch cannot interact at all.

## Fallback ladder (plain fetch first, then escalate)

When it is unclear, try the plain fetch, then escalate to a full browser if the
response shows it was blocked or unrendered:

- Empty or near-empty body, or an HTML shell with no real content.
- A JavaScript-required notice ("You need to enable JavaScript to run this app", "Please enable cookies").
- A redirect to a login/sign-in page instead of the requested content.
- HTTP 403 / 429 / captcha challenge.

Any of these → re-do the request with a full browser rather than reporting the
fetched shell as the answer.

## Using a full browser

A full browser is a host capability, not a listed MCP server; its browser tools
become available when the host's browser integration is connected (under Claude
Code, the Claude in Chrome extension). To use it: open/navigate the tab to the
target URL and read the rendered page through those tools.

If no full-browser capability is available in the session, do not silently fall
back to the plain-fetch shell. Tell the user a full browser must be
enabled/connected (they may need to open their browser and connect the
integration), and let them decide.

## Out of scope

- **Keyword search with no specific URL** — use a web-search tool to find pages first.
- **A source already covered by a dedicated integration** — prefer the purpose-built tools over scraping the web UI: GitHub, Linear, Jira/Confluence, Google Drive/Docs each have dedicated MCP servers. Only browse those sites in a full browser when the integration genuinely cannot reach what is needed.
