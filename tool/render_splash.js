// Renders the launch screen logo from assets/icon/splash.svg:
//   node tool/render_splash.js assets/icon/splash.svg android/app/src/main/res [preview.png]
// The design is 1152 px square, 288 dp at the highest density, which is the
// canvas Android 12 gives the splash icon. The background rectangle is
// dropped: the window paints the colour itself.
const { chromium } = require('playwright');
const fs = require('fs');
const [,, src, res, preview] = process.argv;
const svg = fs.readFileSync(src, 'utf8');
const logo = svg.replace(/<rect width="1152" height="1152" fill="#37563B"\/>/, '');
if (logo === svg) throw new Error('background not found');
const dens = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };
(async () => {
  const b = await chromium.launch();
  const page = await b.newPage();
  async function shot(markup, size, out, background) {
    await page.setViewportSize({ width: size, height: size });
    await page.setContent(`<style>html,body{margin:0;background:${background || 'transparent'}}svg{display:block;width:${size}px;height:${size}px}</style>${markup}`);
    await page.screenshot({ path: out, omitBackground: !background });
  }
  for (const [d, k] of Object.entries(dens)) {
    fs.mkdirSync(`${res}/drawable-${d}`, { recursive: true });
    await shot(logo, Math.round(288 * k), `${res}/drawable-${d}/splash_logo.png`);
  }
  // The circle is what Android 12 keeps of the icon.
  if (preview) await shot(logo + '<div style="position:fixed;inset:0"><div style="position:absolute;left:16.667%;top:16.667%;width:66.667%;height:66.667%;border:2px dashed #fff8;border-radius:50%;box-sizing:border-box"></div></div>', 576, preview, '#37563B');
  await b.close();
})();
