
document.getElementById('expand-stack-list').onclick = ->
  document.getElementById('stack-list').classList.toggle('expanded')
  false
# $ ->
#   $('#expand-stack-list').click (event) ->
#     $('#stack-list').slideToggle()
#     event.preventDefault() and false


  # $(window).resize ->
  #   elements = $('#testimonials .col-md-3')
  #   max = 0
  #   for elem in elements
  #     height = $(elem).height()
  #     max = height if height > max
  #   console.log max
  #   elements.height max

  #  $(window).trigger 'resize'