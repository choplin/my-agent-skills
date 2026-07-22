# Playwright browser recording

Read this reference when recording a local HTML/web app through Playwright, especially on macOS with Nix. Adapt paths and selectors to the project; do not put a machine-specific Nix store path in a reusable project script.

## Setup

Use a temporary environment when the project does not already supply Playwright and ffmpeg:

```sh
nix-shell -p nodejs playwright ffmpeg
```

Use `recordVideo` on the browser context. A static recording target should normally be self-contained and opened with `pathToFileURL()`. On macOS, launch the installed Chrome by its executable path when the bundled Playwright browser is unavailable. If normal `playwright` import resolution fails in Nix, locate the installed `playwright-core` `index.mjs` and dynamically import it; never hard-code a previously observed `/nix/store/...` path.

## Minimal lifecycle

```js
import { mkdirSync, renameSync } from "node:fs";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import { chromium } from "playwright";

const outputDir = "recordings";
const finalPath = join(outputDir, "demo.webm");
mkdirSync(outputDir, { recursive: true });

const browser = await chromium.launch({
  executablePath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  headless: true,
});
const context = await browser.newContext({
  viewport: { width: 1440, height: 960 },
  deviceScaleFactor: 1,
  recordVideo: { dir: outputDir, size: { width: 1440, height: 960 } },
});
const page = await context.newPage();
await page.goto(pathToFileURL("index.html").href, { waitUntil: "load" });

// Execute the planned demonstration here.

const video = page.video();
await context.close(); // Finish encoding before asking for video.path().
await browser.close();
renameSync(await video.path(), finalPath);
```

Use one fixed final name. Remove/overwrite only the prior artifact at that known path when the task authorizes it; do not create a trail of alternate final names.

## Visible interaction helpers

Headless capture does not include the physical pointer. Inject a page-level cursor and pulse overlay, then have helpers move the actual mouse and the overlay together. Use an arrow by default and a hand over clickable targets. Keep the implementation local to the capture script.

For a click: smooth-scroll the target into a comfortably visible area, read its bounding box, move in about 8–12 steps to its center, pulse the overlay, then click. Do not call a jumpy visibility helper as the viewer-facing scroll action.

```js
async function smoothScrollToLocator(page, locator) {
  const target = locator.first();
  await target.waitFor({ state: "visible" });
  const visible = await target.evaluate((el) => {
    const r = el.getBoundingClientRect();
    return r.top >= 80 && r.bottom <= innerHeight - 60;
  });
  if (!visible) {
    await target.evaluate((el) => el.scrollIntoView({
      behavior: "smooth", block: "center", inline: "nearest",
    }));
    await page.waitForTimeout(450);
  }
}

async function clickLocator(page, locator) {
  await smoothScrollToLocator(page, locator);
  const box = await locator.first().boundingBox();
  const x = Math.round(box.x + box.width / 2);
  const y = Math.round(box.y + box.height / 2);
  await page.mouse.move(x, y, { steps: 12 });
  await page.evaluate(([x, y]) => {
    window.__demoCursorSet?.(x, y, "pointer");
    window.__demoCursorClick?.();
  }, [x, y]);
  await page.mouse.click(x, y);
}
```

Emulate typing only when the viewer needs to understand a human judgment or response. Reveal a short representative input character-by-character (roughly 20 ms per character); let repeated inputs complete automatically. Hold important states for a few seconds.

## Check the result

```sh
ffprobe -v error -show_entries format=duration,size \
  -of default=noprint_wrappers=1 recordings/demo.webm
```

Review the video itself as well: metadata cannot detect a cursor jump, unreadable UI, accidental notification, or a missing before/after state.
