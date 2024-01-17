source("functions.R")

poll_name_ref <- "3a eliminação"
poll_date_ref <- lubridate::as_datetime(
  x = "2024-01-16 21:00:00", 
  tz = "America/Sao_Paulo"
)

polls_list <- list(
  list(
    poll_name = poll_name_ref, 
    poll_type = "sites",
    poll_date = poll_date_ref, 
    poll_img_url = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgzQwtXJlz5kSmr0gVsMclRInUNM4cZpNKYcct5qLGXIea79YOTOIrzVrK1hIkUDeYiClECbENnhB2GIZucJyqMzTqMQ7Gsqv3ycE_26Ke5Ay4hcmsXdBeeneKtH_T3m12m-u5Lp5OxrSVRGSXFkHLqLRuB6Jv_eWkDCFZlXpzWeei7QVALE07RxvnwWOE/s682/2024-01-16_205626.jpg"
  ),
  list(
    poll_name = poll_name_ref, 
    poll_type = "twitter",
    poll_date = poll_date_ref, 
    poll_img_url = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgK4ztm6CE5mwCI1TFezFNJW8tpflLv0OpVrAefLwgWwzSNmhOs2ez6t5fklR7lrdu7BttLYX1RCe-22dDnPeo-NePBBGmNFPdx82RoMIMmZQn48PkhRBflkgqLx8OGX6cbuEK6jzDaYokK3aWEqEtZRROjqkWIiXX2OueT4Yiqsu7CbS6rYnFWTPN2dMU/s709/2024-01-16_205653.jpg"
  ),
  list(
    poll_name = poll_name_ref, 
    poll_type = "youtube",
    poll_date = poll_date_ref, 
    poll_img_url = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjttyf-5ErdWHz3DJBIXSWl9fnQYRVWBIlsEnkzKar3vj7hlnJ1YpI7lwTY6plqRj12tSlzp-zLaweQtro5LJJ1qLFawG9x65fs_Iujc8dPKYztRSxg6ABlVWl-ojlsMiYaYilc0X_yAWNYk314JJ98T-RJtAyEBB3u8QRvGp_VDluUi34ipL8ZYofZldg/s685/2024-01-16_205717.jpg"
  ),
  list(
    poll_name = poll_name_ref, 
    poll_type = "telegram",
    poll_date = poll_date_ref, 
    poll_img_url = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEggqI-GL4Evp9vKt6G3FY6QMs0Sxjw90hpMcXn-N4U2bFVfwn-eAa1fe1gtGiMCo2z1l8CIojcfugHj1VZR1Wgu7uQ5kSZNL0kkiZc-faXFUqRIZXk3q3-inPvs1CJcus1pmY1cCzNvjCwyCh0UlXtgVngPKIR9ocC5iO18CYm4IznCfl5X3KuTQEWQiAA/s487/2024-01-16_205746.jpg"
  )
)

poll_results <- purrr::map(
  .x = polls_list, 
  .f = function(x){
    scrap_poll(x$poll_name, x$poll_type, x$poll_date, x$poll_img_url)
  } 
) |>
  purrr::list_rbind()




conn <- DBI::dbConnect(duckdb::duckdb(), "polls.duckdb")

DBI::dbWriteTable(conn = conn, name = "polls", value = poll_results, append = TRUE)

DBI::dbDisconnect(conn, shutdown = TRUE)
