// Dropped into the "lastline" Firefox profile by install.sh.
// Two jobs: force the dark UI + local homepage, and silence every
// first-run / onboarding popup that would otherwise ruin a take.

// --- look ---
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
user_pref("layout.css.prefers-color-scheme.content-override", 0); // 0 = dark
user_pref("browser.tabs.drawInTitlebar", true);

// --- homepage ---
user_pref("browser.startup.homepage", "__HOMEPAGE__");
user_pref("browser.startup.page", 1);
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtab.url", "__HOMEPAGE__");

// --- quiet for filming: no onboarding, no update nags, no telemetry pings ---
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("browser.startup.homepage_override.buildID", "");
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("browser.discovery.enabled", false);
user_pref("extensions.pocket.enabled", false);
user_pref("browser.tabs.firefox-view", false);
user_pref("app.update.auto", false);
user_pref("app.update.silent", true);
