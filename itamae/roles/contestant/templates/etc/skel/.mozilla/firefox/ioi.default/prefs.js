//

user_pref("browser.startup.homepage", "<%= node[:contestant][:cms_uri] %>");
user_pref("browser.startup.homepage_override.mstone", "ignore");

user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);

user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
