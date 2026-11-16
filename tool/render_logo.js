// Renders the launcher icons and the launch screen logo from
// assets/icon/logo.svg, a 1152 px square: the lettering on the brand colour.
//   node tool/render_logo.js assets/icon/logo.svg android/app/src/main/res <preview dir>
const { chromium } = require('playwright');
const fs = require('fs');
const [,, src, res, preview] = process.argv;
const svg = fs.readFileSync(src, 'utf8');
const BRAND = '#37563B';
// The lettering alone: the window and the launcher paint the colour.
const inner = svg.replace(/^[\s\S]*?<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '');
const text = inner.replace(/<rect width="1152" height="1152" fill="#37563B"\/>/, '');
if (text.includes('<rect')) throw new Error('background not removed');
const dens = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };
(async () => {
  const b = await chromium.launch();
  const page = await b.newPage();
  async function shot(markup, size, out) {
    await page.setViewportSize({ width: size, height: size });
    await page.setContent(`<style>html,body{margin:0;background:transparent}svg{display:block;width:${size}px;height:${size}px}</style>${markup}`);
    await page.screenshot({ path: out, omitBackground: true });
  }
  // Where the lettering really is, so that it sits in the exact middle.
  await page.setContent(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1152 1152"><g id="t">${text}</g></svg>`);
  const box = await page.evaluate(() => {
    const r = document.getElementById('t').getBBox();
    return { cx: r.x + r.width / 2, cy: r.y + r.height / 2, w: r.width, h: r.height };
  });
  const radius = Math.hypot(box.w, box.h) / 2;
  // A square view of the design, `side` units wide, around the lettering.
  const view = (side, extra = '') =>
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${box.cx - side / 2} ${box.cy - side / 2} ${side} ${side}" fill="none">${extra}${text}</svg>`;
  // Adaptive icon: a 108dp canvas of which launchers show the middle 72dp
  // and guarantee a 66dp circle. The lettering fills a 62dp circle.
  const unit = 31 / radius; // dp per design unit
  const fg = view(108 / unit);
  // Launch screen: Android 12 shows a circle two thirds of the canvas wide.
  const splash = view(radius * 2 / (2 / 3 * 0.92));
  // Old launchers: the 72dp part on a rounded square.
  const side = 72 / unit;
  const legacy = view(side, `<rect x="${box.cx - side / 2}" y="${box.cy - side / 2}" width="${side}" height="${side}" rx="${side * 0.22}" fill="${BRAND}"/>`);
  for (const [d, k] of Object.entries(dens)) {
    fs.mkdirSync(`${res}/mipmap-${d}`, { recursive: true });
    fs.mkdirSync(`${res}/drawable-${d}`, { recursive: true });
    await shot(legacy, Math.round(48 * k), `${res}/mipmap-${d}/ic_launcher.png`);
    await shot(fg, Math.round(108 * k), `${res}/mipmap-${d}/ic_launcher_foreground.png`);
    await shot(splash, Math.round(288 * k), `${res}/drawable-${d}/splash_logo.png`);
  }
  if (preview) {
    const on = (shape, markup) => `<div style="width:432px;height:432px;background:${BRAND};${shape};overflow:hidden">${markup.replace('<svg ', '<svg style="width:648px;height:648px;margin:-108px" ')}</div>`;
    await shot(on('border-radius:50%', fg), 432, preview + '/icon_round.png');
    await shot(on('border-radius:28%', fg), 432, preview + '/icon_squircle.png');
    await shot(legacy, 432, preview + '/icon_legacy.png');
    await page.setViewportSize({ width: 360, height: 800 });
    await page.setContent(`<style>html,body{margin:0;height:100%;background:${BRAND}}div{height:100%;display:flex;align-items:center;justify-content:center}svg{width:288px;height:288px}</style><div>${splash}</div>`);
    await page.screenshot({ path: preview + '/splash_phone.png' });
  }
  await b.close();
})();
