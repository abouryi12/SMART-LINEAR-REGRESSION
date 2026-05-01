styles <- readLines("www/styles.css")
styles <- gsub("--bg0:#000000;--bg1:#050505;--bg2:#0a0a0a;--bg3:#111111;--bgi:#080808;", "--bg0:#080808;--bg1:#0d0000;--bg2:#0d0000;--bg3:#0d0000;--bgi:#080808;", styles, fixed=TRUE)
styles <- gsub("--brd:rgba(255,0,60,.2);--brd-a:rgba(255,0,60,.6);", "--brd:#660000;--brd-a:#cc0000;", styles, fixed=TRUE)
styles <- gsub("--blue:#ff003c;--blue2:#e60036;--cyan:#ff5500;--azure:#ff1100;", "--blue:#ff1a1a;--blue2:#ff2020;--cyan:#ff2020;--azure:#ff1a1a;", styles, fixed=TRUE)
styles <- gsub("--purple:#ff0055;--green:#ffea00;--orange:#ff8c00;--red:#ff0000;", "--purple:#cc0000;--green:#ff2020;--orange:#ff1a1a;--red:#ff2020;", styles, fixed=TRUE)
styles <- gsub("--grad:linear-gradient(135deg,#ff003c,#ff5500);", "--grad:linear-gradient(135deg,#cc0000,#ff2020);", styles, fixed=TRUE)
styles <- gsub("--grad2:linear-gradient(135deg,#ff5500,#ffea00);", "--grad2:linear-gradient(135deg,#ff2020,#cc0000);", styles, fixed=TRUE)
styles <- gsub("--glow-blue:0 0 20px rgba(255,0,60,.4),0 0 60px rgba(255,0,60,.15);", "--glow-blue:0 0 20px rgba(255,26,26,.4),0 0 60px rgba(255,26,26,.15);", styles, fixed=TRUE)
styles <- gsub("--glow-cyan:0 0 20px rgba(255,85,0,.3),0 0 60px rgba(255,85,0,.1);", "--glow-cyan:0 0 20px rgba(255,32,32,.3),0 0 60px rgba(255,32,32,.1);", styles, fixed=TRUE)
styles <- gsub("--glow-sm:0 0 12px rgba(255,0,60,.3);", "--glow-sm:0 0 12px rgba(255,26,26,.3);", styles, fixed=TRUE)

styles <- gsub("rgba(5,5,5,.85)", "rgba(13,0,0,.85)", styles, fixed=TRUE)
styles <- gsub("rgba(255,0,60,", "rgba(255,26,26,", styles, fixed=TRUE)
styles <- gsub("rgba(255,85,0,", "rgba(255,32,32,", styles, fixed=TRUE)
styles <- gsub("rgba(255,0,85,", "rgba(204,0,0,", styles, fixed=TRUE)
styles <- gsub("rgba(255,234,0,", "rgba(255,32,32,", styles, fixed=TRUE)
styles <- gsub("rgba(255,140,0,", "rgba(255,26,26,", styles, fixed=TRUE)
writeLines(styles, "www/styles.css")

gl <- readLines("global.R")
gl <- gsub("#050505", "#080808", gl, fixed=TRUE)
gl <- gsub("#ff003c15", "#ff1a1a15", gl, fixed=TRUE)
writeLines(gl, "global.R")

sr <- readLines("server.R")
sr <- gsub("bg = \"#050505\"", "bg = \"#080808\"", sr, fixed=TRUE)

# scatter_plot
sr <- gsub("geom_point(color = \"#ff003c\"", "geom_point(color = \"#ff1a1a\"", sr, fixed=TRUE)
sr <- gsub("geom_smooth(method = \"lm\", color = \"#ff5500\", fill = \"#ff550014\"", "geom_smooth(method = \"lm\", color = \"#ff1a1a\", fill = \"#ff1a1a14\"", sr, fixed=TRUE)

# actual_vs_pred
sr <- gsub("geom_point(color = \"#ffea00\"", "geom_point(color = \"#ff2020\"", sr, fixed=TRUE)
sr <- gsub("geom_abline(slope = 1, intercept = 0, color = \"#ff003c\"", "geom_abline(slope = 1, intercept = 0, color = \"#cc0000\"", sr, fixed=TRUE)

# residual_plot
sr <- gsub("geom_hline(yintercept = 0, color = \"#ff003c\"", "geom_hline(yintercept = 0, color = \"#cc0000\"", sr, fixed=TRUE)
sr <- gsub("geom_point(color = \"#ff0055\"", "geom_point(color = \"#ff1a1a\"", sr, fixed=TRUE)
sr <- gsub("geom_smooth(method = \"loess\", color = \"#ff5500\"", "geom_smooth(method = \"loess\", color = \"#ff4040\"", sr, fixed=TRUE)

# residual_hist
sr <- gsub("geom_histogram(fill = \"#ff003c\", color = \"#050505\"", "geom_histogram(fill = \"#cc0000\", color = \"#080808\"", sr, fixed=TRUE)
sr <- gsub("geom_density(aes(y = after_stat(count)), color = \"#ff5500\"", "geom_density(aes(y = after_stat(count)), color = \"#ff2020\"", sr, fixed=TRUE)

# coef_importance_plot
sr <- gsub("scale_fill_gradient(low = \"#ff003c\", high = \"#ffea00\")", "scale_fill_gradient(low = \"#cc0000\", high = \"#ff2020\")", sr, fixed=TRUE)

# qq_plot
sr <- gsub("geom_point(color = \"#ff5500\"", "geom_point(color = \"#ff1a1a\"", sr, fixed=TRUE)
sr <- gsub("geom_abline(slope = sd(res), intercept = mean(res), color = \"#ff003c\"", "geom_abline(slope = sd(res), intercept = mean(res), color = \"#cc0000\"", sr, fixed=TRUE)

# health_score
sr <- gsub("color <- if(score >= 80) \"#ffea00\" else if(score >= 60) \"#ff8c00\" else \"#ff003c\"", "color <- if(score >= 80) \"#ff2020\" else if(score >= 60) \"#cc0000\" else \"#660000\"", sr, fixed=TRUE)

# summary text colors
sr <- gsub("color:#ffea00", "color:#ff2020", sr, fixed=TRUE)
sr <- gsub("color:#ff8c00", "color:#ff1a1a", sr, fixed=TRUE)
sr <- gsub("color:#ff003c", "color:#cc0000", sr, fixed=TRUE)

writeLines(sr, "server.R")
