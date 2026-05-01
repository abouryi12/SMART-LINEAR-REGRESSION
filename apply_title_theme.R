# apply_title_theme.R
styles <- readLines("www/styles.css")

# 1. Replace the :root block completely
root_start <- grep(":root\\{", styles)
root_end <- grep("\\}", styles[root_start:length(styles)])[1] + root_start - 1

new_root <- c(
  ":root{",
  "  --bg0:#080808;--bg1:#0a0000;--bg2:#0d0000;--bg3:#110000;--bgi:#080808;",
  "  --brd:rgba(255,26,26,.2);--brd-a:rgba(255,26,26,.6);",
  "  --t1:#ffffff;--t2:#d0d0d0;--t3:#a0a0a0;",
  "  --blue:#ff1a1a;--blue2:#cc0000;--cyan:#cfa85f;--azure:#ff1a1a;",
  "  --purple:#cfa85f;--green:#ffffff;--orange:#cfa85f;--red:#ff1a1a;",
  "  --grad:linear-gradient(135deg,#ff1a1a,#cc0000);",
  "  --grad2:linear-gradient(135deg,#cfa85f,#a8803c);",
  "  --glow-blue:0 0 20px rgba(255,26,26,.4),0 0 60px rgba(255,26,26,.15);",
  "  --glow-cyan:0 0 20px rgba(207,168,95,.4),0 0 60px rgba(207,168,95,.15);",
  "  --glow-sm:0 0 12px rgba(255,26,26,.5);",
  "  --r:0px;--tr:.3s cubic-bezier(.4,0,.2,1);",
  "}"
)

styles <- c(styles[1:(root_start-1)], new_root, styles[(root_end+1):length(styles)])

# 2. Replace hardcoded rgb/rgba in styles.css
styles <- gsub("rgba\\(0,174,239,", "rgba(255,26,26,", styles)
styles <- gsub("rgba\\(0,238,255,", "rgba(207,168,95,", styles)
styles <- gsub("rgba\\(176,0,255,", "rgba(255,26,26,", styles)
styles <- gsub("rgba\\(0,255,170,", "rgba(255,255,255,", styles)
styles <- gsub("rgba\\(255,136,0,", "rgba(207,168,95,", styles)
styles <- gsub("rgba\\(5,5,5,", "rgba(13,0,0,", styles)

# Fix .text-red which I might have missed
styles <- gsub("rgba\\(255,0,60,", "rgba(255,26,26,", styles)

# Fix some specific classes in styles.css
styles <- gsub("color:#f0f0f0", "color:#ffffff", styles)
styles <- gsub("color:#ffaa00", "color:#cfa85f", styles)
styles <- gsub("color:#ff6b2b", "color:#ff1a1a", styles)
styles <- gsub("rgba\\(240,240,240,", "rgba(255,255,255,", styles)
styles <- gsub("rgba\\(255,170,0,", "rgba(207,168,95,", styles)
styles <- gsub("rgba\\(255,107,43,", "rgba(255,26,26,", styles)

writeLines(styles, "www/styles.css")


# 3. Update global.R
gl <- readLines("global.R")
gl <- gsub("#050505", "#080808", gl, fixed=TRUE)
gl <- gsub("#111111", "#110000", gl, fixed=TRUE)
gl <- gsub("#0a0a0a", "#0a0000", gl, fixed=TRUE)
gl <- gsub("#00aeff40", "#ff1a1a20", gl, fixed=TRUE)
gl <- gsub("#00aeff15", "#ff1a1a15", gl, fixed=TRUE)
gl <- gsub("#b000ff", "#cc0000", gl, fixed=TRUE)
writeLines(gl, "global.R")


# 4. Update server.R
sr <- readLines("server.R")
sr <- gsub("bg = \"#050505\"", "bg = \"#080808\"", sr, fixed=TRUE)

# Hex replacements for plots
sr <- gsub("color = \"#00aeff\"", "color = \"#ff1a1a\"", sr, fixed=TRUE)
sr <- gsub("color = \"#00eeff\"", "color = \"#cfa85f\"", sr, fixed=TRUE)
sr <- gsub("color = \"#00ffaa\"", "color = \"#ffffff\"", sr, fixed=TRUE)
sr <- gsub("color = \"#b000ff\"", "color = \"#cfa85f\"", sr, fixed=TRUE)

sr <- gsub("fill = \"#00eeff14\"", "fill = \"#cfa85f14\"", sr, fixed=TRUE)
sr <- gsub("fill = \"#00aeff\"", "fill = \"#ff1a1a\"", sr, fixed=TRUE)

# Fix specific geom_points
sr <- gsub("geom_point(color = \"#ff1a1a\", alpha = 0.8, size = 3)", "geom_point(color = \"#cfa85f\", alpha = 0.8, size = 3)", sr, fixed=TRUE)
sr <- gsub("geom_point(color = \"#ffffff\", size = 3, alpha = 0.8)", "geom_point(color = \"#ffffff\", size = 3, alpha = 0.8)", sr, fixed=TRUE)
sr <- gsub("geom_point(color = \"#cfa85f\", alpha = 0.6)", "geom_point(color = \"#cfa85f\", alpha = 0.6)", sr, fixed=TRUE)
sr <- gsub("geom_point(color = \"#cfa85f\", alpha = 0.6, size = 3)", "geom_point(color = \"#cfa85f\", alpha = 0.6, size = 3)", sr, fixed=TRUE)

sr <- gsub("geom_hline(yintercept = 0, color = \"#ff1a1a\"", "geom_hline(yintercept = 0, color = \"#ffffff\"", sr, fixed=TRUE)

sr <- gsub("low = \"#ff1a1a\", high = \"#cfa85f\"", "low = \"#ff1a1a\", high = \"#cfa85f\"", sr, fixed=TRUE)

# Health score
sr <- gsub("color <- if(score >= 80) \"#ffffff\" else if(score >= 60) \"#cfa85f\" else \"#ff1a1a\"", "color <- if(score >= 80) \"#ffffff\" else if(score >= 60) \"#cfa85f\" else \"#ff1a1a\"", sr, fixed=TRUE)

# Summary text colors
sr <- gsub("color:#ffffff", "color:#ffffff", sr, fixed=TRUE)
sr <- gsub("color:#cfa85f", "color:#cfa85f", sr, fixed=TRUE)
sr <- gsub("color:#ff1a1a", "color:#ff1a1a", sr, fixed=TRUE)

writeLines(sr, "server.R")


# 5. Update SVG Icon
svg <- readLines("www/beta_regression_icon.svg")
svg <- gsub("#00aeff", "#ff1a1a", svg)
svg <- gsub("#b000ff", "#cfa85f", svg)
svg <- gsub("#00eeff", "#cfa85f", svg)
svg <- gsub("rgb\\(176, 0, 255\\)", "rgb(207, 168, 95)", svg)
svg <- gsub("rgb\\(0, 174, 239\\)", "rgb(255, 26, 26)", svg)
svg <- gsub("rgb\\(0, 238, 255\\)", "rgb(207, 168, 95)", svg)
writeLines(svg, "www/beta_regression_icon.svg")

cat("Theme applied successfully!\n")
