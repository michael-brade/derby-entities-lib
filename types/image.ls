previewFile = ->
    preview = document.querySelector('img')
    file    = document.querySelector('input[type=file]').files[0]
    reader  = new FileReader!

    reader.onloadend = ->
        preview.src = reader.result


    if file
        reader.readAsDataURL(file)
    else
        preview.src = ""
