// Copy this into mcp__playwright__browser_evaluate as the `function` arg.
// Returns timing + size metrics for whatever page is currently loaded.

() => {
  const nav = performance.getEntriesByType('navigation')[0];
  const paint = performance.getEntriesByType('paint');
  const resources = performance.getEntriesByType('resource');
  const totalBytes = resources.reduce((s, r) => s + (r.transferSize || 0), 0);
  return {
    ttfb_ms: Math.round(nav.responseStart - nav.requestStart),
    fcp_ms: Number(paint.find(p => p.name === 'first-contentful-paint')?.startTime?.toFixed(0)),
    domContentLoaded_ms: Math.round(nav.domContentLoadedEventEnd - nav.startTime),
    loadComplete_ms: Math.round(nav.loadEventEnd - nav.startTime),
    resourceCount: resources.length,
    totalKB: Math.round(totalBytes / 1024),
    totalMB: Number((totalBytes / 1024 / 1024).toFixed(2)),
    cfRequestDuration_ms: nav.serverTiming?.find(s => s.name === 'cfRequestDuration')?.duration ?? null,
    via: nav.nextHopProtocol
  };
}
