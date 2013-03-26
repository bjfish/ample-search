# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  updateIndexStatus = (data) ->
    $.get "/integrations/" + data + "/job_status", (data) ->
      $("#index-status-" + data.integration_id).html data.message  if data.message
      if data.status isnt "completed" and data.status isnt "failed"
        setTimeout (->
          updateIndexStatus data.integration_id
        ), 1000
  $(".indexing").each (index, div) ->
    setTimeout (->
      updateIndexStatus $(div).attr("data-id")
    ), 1000
  $(".retrieve").click ->
    $.post "/integrations/" + $(this).attr("data-id") + "/index_now", (data) ->
      setTimeout (->
        updateIndexStatus data.id
      ), 1000
)
