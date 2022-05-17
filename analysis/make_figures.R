library(tidyverse)
library(patchwork)
library(survival)

# load outcomes
if (Sys.info()["sysname"] == "Darwin") {
  root_dir <- "/Volumes/lss_jsimmeri_backup/data/tz-5ari-final"
} else {
  root_dir <- "/Shared/lss_jsimmeri_backup/data/tz-5ari-final"
}
model_data <- read_rds(glue::glue("{root_dir}/treated_model_data.rds"))
outcomes <- model_data %>%
  select(enrolid, drug, develops_pd, survival_time)

# load matches
tz_tam_matches <- read_rds(glue::glue("{root_dir}/matches/tz_tam.rds")) %>%
  mutate(enrolid = as.numeric(enrolid))
tz_5ari_matches <- read_rds(glue::glue("{root_dir}/matches/tz_5ari.rds")) %>%
  mutate(enrolid = as.numeric(enrolid))
tam_5ari_matches <- read_rds(glue::glue("{root_dir}/matches/tam_5ari.rds")) %>%
  mutate(enrolid = as.numeric(enrolid))

# make paired outcomes tibbles
outcomes_tz_tam <- inner_join(outcomes, tz_tam_matches, by = c("enrolid"))
outcomes_tz_5ari <- inner_join(outcomes, tz_5ari_matches, by = c("enrolid"))
outcomes_tam_5ari <- inner_join(outcomes, tam_5ari_matches, by = c("enrolid"))

# Figure 1
tz_tam_km <- survfit(Surv(survival_time, develops_pd) ~ treatment, data = outcomes_tz_tam) %>%
  broom::tidy() %>%
  mutate(
    g = ifelse(strata == "treatment=1", "TZ/DZ/AZ", "Tamsulosin")
  ) %>%
  ggplot(aes(x = time / 365, 
             y = estimate * 100, 
             ymin = conf.low * 100, 
             ymax = conf.high * 100)) + 
  geom_step(aes(color = g)) + 
  geom_ribbon(aes(fill = g), alpha = 0.33) + 
  labs(x = "Years Since Medication Start", y = "Percent Remaining\nPD Free") + 
  theme_bw() +
  theme(legend.position = "none") +
  scale_color_manual(values = c("#00BA38", "#F8766D")) + 
  scale_fill_manual(values = c("#00BA38", "#F8766D")) + 
  annotate("text", x = 10, y = 98.5, label = "TZ/DZ/AZ", size = 3,
           color = "#F8766D") + 
  annotate("text", x = 8.5, y = 95, label = "Tamsulosin", size = 3,
           color = "#00BA38")

tz_5ari_km <- survfit(Surv(survival_time, develops_pd) ~ treatment, data = outcomes_tz_5ari) %>%
  broom::tidy() %>%
  mutate(
    g = ifelse(strata == "treatment=1", "TZ/DZ/AZ", "Tamsulosin")
  ) %>%
  ggplot(aes(x = time / 365, 
             y = estimate * 100, 
             ymin = conf.low * 100, 
             ymax = conf.high * 100)) + 
  geom_step(aes(color = g)) + 
  geom_ribbon(aes(fill = g), alpha = 0.33) + 
  labs(x = "Years Since Medication Start", y = "Percent Remaining\nPD Free") + 
  theme_bw() +
  theme(legend.position = "none") +
  scale_color_manual(values = c("#619CFF", "#F8766D")) + 
  scale_fill_manual(values = c("#619CFF", "#F8766D")) + 
  annotate("text", x = 10, y = 98.5, label = "TZ/DZ/AZ", size = 3,
           color = "#F8766D") + 
  annotate("text", x = 8.5, y = 96.5, label = "5ARI", size = 3,
           color = "#619CFF")

tam_5ari_km <- survfit(Surv(survival_time, develops_pd) ~ treatment, data = outcomes_tam_5ari) %>%
  broom::tidy() %>%
  mutate(
    g = ifelse(strata == "treatment=1", "Tamsulosin", "5ARI")
  ) %>%
  ggplot(aes(x = time / 365, 
             y = estimate * 100, 
             ymin = conf.low * 100, 
             ymax = conf.high * 100)) + 
  geom_step(aes(color = g)) + 
  geom_ribbon(aes(fill = g), alpha = 0.33) + 
  labs(x = "Years Since Medication Start", y = "Percent Remaining\nPD Free") + 
  theme_bw() +
  theme(legend.position = "none") +
  scale_color_manual(values = c("#619CFF", "#00BA38")) + 
  scale_fill_manual(values = c("#619CFF", "#00BA38")) + 
  annotate("text", x = 10, y = 98, label = "5ARI", size = 3,
           color = "#619CFF") + 
  annotate("text", x = 8.5, y = 95.5, label = "Tamsulosin", size = 3,
           color = "#00BA38")

tz_tam_km + tz_5ari_km + tam_5ari_km +
  plot_layout(nrow = 3) + 
  plot_annotation(tag_levels = "A")
ggsave("~/projects/pd-preprint/km-plot.png", width = 4.5, height = 8)

# figure S1
cph_tz_tam <- coxph(Surv(survival_time, develops_pd) ~ treatment, data = outcomes_tz_tam)
zph_tz_tam <- cox.zph(cph_tz_tam)

cph_tz_5ari <- coxph(Surv(survival_time, develops_pd) ~ treatment, data = outcomes_tz_5ari)
zph_tz_5ari <- cox.zph(cph_tz_5ari)

cph_tam_5ari <- coxph(Surv(survival_time, develops_pd) ~ treatment, data = outcomes_tam_5ari)
zph_tam_5ari <- cox.zph(cph_tam_5ari)

tibble(
  x = c(
    zph_tz_tam$time,
    zph_tz_5ari$time,
    zph_tam_5ari$time
  ),
  y = c(
    zph_tz_tam$y[, 1],
    zph_tz_5ari$y[, 1],
    zph_tam_5ari$y[, 1]
  ),
  true = c(
    rep(coef(cph_tz_tam), NROW(zph_tz_tam$x)),
    rep(coef(cph_tz_5ari), NROW(zph_tz_5ari$x)),
    rep(coef(cph_tam_5ari), NROW(zph_tam_5ari$x))
  ),
  lb = c(
    rep(confint(cph_tz_tam)[1], NROW(zph_tz_tam$x)),
    rep(confint(cph_tz_5ari)[1], NROW(zph_tz_5ari$x)),
    rep(confint(cph_tam_5ari)[1], NROW(zph_tam_5ari$x))
  ),
  ub = c(
    rep(confint(cph_tz_tam)[2], NROW(zph_tz_tam$x)),
    rep(confint(cph_tz_5ari)[2], NROW(zph_tz_5ari$x)),
    rep(confint(cph_tam_5ari)[2], NROW(zph_tam_5ari$x))
  ),
  label = c(
    rep("TZ/DZ/AZ vs Tamsulosin", NROW(zph_tz_tam$x)),
    rep("TZ/DZ/AZ vs 5ARI", NROW(zph_tz_5ari$x)),
    rep("Tamsulosin vs 5ARI", NROW(zph_tam_5ari$x))
  )
) %>%
  mutate(
    label = forcats::fct_relevel(label, "TZ/DZ/AZ vs Tamsulosin", "TZ/DZ/AZ vs 5ARI")
  ) %>%
  ggplot(aes(x = x / 365, y = y)) + 
  geom_smooth(method = "loess") + 
  geom_point(alpha = 0.25) + 
  geom_line(aes(y = true), linetype = 2) +
  geom_line(aes(y = lb), linetype = 3) +
  geom_line(aes(y = ub), linetype = 3) +
  facet_grid(cols = vars(label)) +
  theme_bw() +
  labs(x = "Years Since Medication Start", y = "Beta(t)")
ggsave("~/projects/pd-preprint/scf_residuals.png", width = 6, height = 4)