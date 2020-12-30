function(input, output, session) {
  # Reactives
  rval_username <- eventReactive(input$show_stats_btn,{
    req(input$username)
    
    exists <- input$username %in% usernames
    shinyFeedback::feedbackDanger("username", !exists, "Username does not exist!")
    req(exists, cancelOutput = TRUE)
    
    input$username
  })
  
  time_by_channel <- reactive({
    req(rval_username(), cancelOutput = TRUE)
    
    bl_pool %>% tbl("time_by_channel")
  })
  
  prog_by_playlist <- reactive({
    req(rval_username(), cancelOutput = TRUE)
    
    bl_pool %>% tbl("prog_by_playlist")
  })
  
  test_scores <- reactive({
    req(rval_username(), cancelOutput = TRUE)
    
    bl_pool %>%
      tbl("vresponsescore") %>%
      left_join(
        bl_pool %>% tbl("users"),
        by = "user_id"
      ) %>%
      left_join(
        bl_pool %>% tbl("test_marks"),
        by = c("test"="test_id","course","module","testmaxscore")
      ) %>%
      mutate(
        pct_score = score/testmaxscore
      )
  })


  # Outputs
  output$time_plot <- renderPlot({
    entered_username <- rval_username()
    time_by_channel() %>%
      filter(username == entered_username) %>%
    ggplot(aes(reorder(playlist,-total_time_spent),total_time_spent,fill = kind)) + 
    geom_bar(stat = "identity") + 
    coord_flip() +
    labs(x = "", y="Total Time Spent (Hours)", fill = "Content Type")  + 
    geom_text(aes(
      label = ifelse(total_time_spent > 1,total_time_spent, '')), 
      position = position_stack(vjust = 0.5),
      color = "white") +
    scale_fill_manual(values = content_colors) +
    ggtitle("Total time spent on each Playlist")
  })
  
  output$time_prop_pieplot <- renderPlot({
    entered_username <- rval_username()
    time_by_channel() %>%
      filter(username == entered_username) %>%
      ggplot(aes(x = 1, y = total_time_spent,fill = kind)) + 
      geom_col() + 
      coord_polar(theta = "y") +
      labs(fill = "Content Type")  +
      scale_fill_manual(values = content_colors) +
      theme_void() +
      ggtitle("Proportion of time spent on each Content Type")
  })
  

  output$progress_plot <- renderPlot({
    entered_username <- rval_username()
    prog_by_playlist() %>%
      filter(username == entered_username) %>%
      ggplot(aes(reorder(playlist,-prog_pct),prog_pct)) + 
      geom_bar(stat = "identity", fill=prog_bar_color) + 
      coord_flip() + 
      labs(x = "", y="Progress") + 
      scale_y_continuous(labels = scales::percent) +
      ggtitle("Percentage progress on each Playlist")
  })
  
  output$tests_table <- DT::renderDT({
    entered_username <- rval_username()
    tests_for_user <- test_scores() %>%
      filter(username == entered_username) %>%
      select(
        test_name,
        test_date,
        pct_score
      ) %>%
      arrange(desc(test_date)) %>%
      collect() %>%
      mutate(test_date = ymd(test_date)) %>%
      mutate(test_date = paste(
        day(test_date),
        month(test_date,label = T),
        year(test_date)))
    DT::datatable(tests_for_user, colnames = c('Test','Test Date','Score')) %>%
      formatStyle(
        'pct_score',
        backgroundColor = styleInterval(test_score_interval, test_score_colors)
      ) %>%
      formatPercentage('pct_score')
  })

  output$full_name <- renderText({
    entered_username <- rval_username()
    prog_by_playlist() %>%
      filter(username == entered_username) %>%
      distinct(full_name) %>% 
      pull(full_name)
    
    })

  output$disclaimer <- renderText("*Note: The inital data load may take a few seconds. Please be patient")
  
}
