
prop_fn <- function(x){
  test_res <- prop.test(x = x$value, x$total_votes) |> 
    broom::tidy()
  
  res <- tibble::tibble(
    poll_name = x$poll_name,
    poll_type = x$poll_type,
    poll_date = x$poll_date,
    source = x$source,
    name = x$name,
    estimate = test_res$estimate,
    conf_low = test_res$conf.low,
    conf_high = test_res$conf.high
  )
  
  return(res)
}


scrap_poll <- function(poll_name, poll_type, poll_date, poll_img_url){
  temp_file <- tempfile(fileext = ".jpg")
  
  magick::image_read(poll_img_url) |>
    magick::image_crop(geometry = magick::geometry_area(400, 10000, 0, 210)) |>
    magick::image_write(path = temp_file)
  
  resp <- daiR::dai_sync_tab(file = temp_file)
  
  unlink(temp_file)
  
  tables <- daiR::tables_from_dai_response(resp)
  
  res <- tables[[1]] |>
    tibble::as_tibble() |>
    dplyr::mutate(
      dplyr::across(dplyr::everything(), \(x) stringr::str_remove_all(x, pattern = '\n')),
      dplyr::across(dplyr::everything(), \(x) stringr::str_replace_all(x, pattern = ',', replacement = ".")),
      dplyr::across(1, \(x) stringr::str_trim(x)),
      dplyr::across(5, \(x) stringr::str_replace_all(x, pattern = '[.]', replacement = "")),
      dplyr::across(2:5, \(x) as.numeric(x))
    ) |>
    janitor::clean_names() |>
    dplyr::rename(source = 1, total_votes = 5) |>
    dplyr::filter(!grepl("Média Ponderada", source)) |>
    dplyr::mutate(dplyr::across(2:4, \(x) x/100*total_votes )) |>
    tidyr::pivot_longer(cols = 2:4) |>
    dplyr::mutate(poll_name = poll_name,
                  poll_type = poll_type, 
                  poll_date = poll_date) |>
    dplyr::group_split(poll_name, poll_type, poll_date, source, name)
  
  poll_result <- purrr::map(res, prop_fn) |> purrr::list_rbind()
  
  return(poll_result)
}




