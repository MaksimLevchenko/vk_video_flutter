/// A class that holds template-related data and methods.
class Template {
  /// A static string that contains HTML content.
  /// Here it is initialized with a simple header element.
  static String html = """
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>rutube_video</title>
    <style>
        * {
            margin: 0px;
            padding: 0;
        }
        body {
            height: 100vh;
            width: 100vw;
            overflow: hidden;
        }
    </style>
</head>
<body>
    <iframe id="rutubeVideo"
        width="100%" height="100%"
        src="https://rutube.ru/play/embed/video/%ID%?js_api=1" 
        allow="autoplay; encrypted-media; fullscreen; picture-in-picture; screen-wake-lock;" 
        frameborder="0" allowfullscreen></iframe>
    <script>
        var player = document.getElementById('rutubeVideo');
        
        // Функция для отправки команд плееру
        function doCommand(commandJSON) {
            player.contentWindow.postMessage(JSON.stringify(commandJSON), '*');
        }
        
        // Обработчик сообщений от Rutube плеера
        window.addEventListener("message", (event) => {
            if (event.data) {
                try {
                    const data = JSON.parse(event.data);
                    const ev_type = data.type;
                    const ev_data = data.data;
                    
                    // Пересылаем сообщение в Dart
                    if (window.flutter_inappwebview) {
                        window.flutter_inappwebview.callHandler('rutubeMessageHandler', {
                            type: ev_type,
                            data: ev_data
                        });
                    }
                    
                    // Обработка специфичных событий (как в вашем примере)
                    switch (ev_type) {
                        case 'player:playComplete':
                            // console.log('Playback completed');
                            break;
                        case 'player:currentTime':
                            // console.log('Current time:', ev_data.time);
                            break;
                        case 'player:playOptionsLoaded':
                            // console.log('Player options loaded');
                            break;
                        case 'player:changeState':
                            // console.log('Player state changed:', ev_data.state);
                            break;
                    }
                } catch(err) {
                    console.error('Error parsing message:', err);
                }
            }
        });
    </script>
</body>
</html>
  """;
  // &hd=%hd%&autoplay=%AUTO_PLAY%&js_api=1&t=%T%
}
