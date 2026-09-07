// Snormium default layout: one floating, translucent bottom panel.
var panels = panelIds;
for (var i = 0; i < panels.length; ++i) { panelById(panels[i]).remove(); }
var panel = new Panel;
panel.location = "bottom";
panel.height = Math.round(gridUnit * 2.6);
panel.floating = true;
panel.alignment = "center";
panel.lengthMode = "fit";
panel.hiding = "none";
panel.opacity = "translucent";
var kickoff = panel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("icon", "snormium-logo");
var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", "applications:org.kde.dolphin.desktop,applications:org.mozilla.firefox.desktop,applications:com.valvesoftware.Steam.desktop,applications:org.kde.konsole.desktop,applications:snormium-welcome.desktop");
panel.addWidget("org.kde.plasma.marginsseparator");
panel.addWidget("org.kde.plasma.systemtray");
var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);
clock.writeConfig("dateFormat", "shortDate");
panel.addWidget("org.kde.plasma.showdesktop");
