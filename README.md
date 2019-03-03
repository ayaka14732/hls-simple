# hls-simple

A simple HLS loop streaming server in Haskell

See [_A Record of Setting up a Live Server_](https://ayaka.shn.hk/live/) (in Chinese)

## Usage

### Build

Prerequisite: [Stack](www.haskellstack.org/)

```sh
stack build
```

### Run

Put the folders that contain `playlist.m3u8` and `*.ts` files in `./static/hls/` folder.

```sh
stack exec -- hls-simple
```

### Test

Save the following as an HTML file, then open it in the browser.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Live Lab</title>
  <script src="https://unpkg.com/video.js/dist/video.min.js"></script>
  <link href="https://unpkg.com/video.js/dist/video-js.min.css" rel="stylesheet" />
</head>
<body>
  <h1>Live Lab</h1>
  <video class="video-js" controls autoplay="true" width="640" data-setup="{}">
    <source src="http://localhost:3000/playlist.m3u8" type="application/vnd.apple.mpegurl" />
  </video>
</body>
</html>
```

## Project Structure

* `main` imports `Handler.PlayList`, `Foundation` and `HLS.PlayList`
* `Handler.PlayList` imports `Foundation` and `HLS.PlayList`
* `Foundation` imports `HLS.PlayList`
* `HLS.PlayList` imports nothing in this project

## Debugging

```haskell
import qualified Data.ByteString.Char8 as BC
t <- getCurrentTime
p <- readAndMergePlayListFiles
BC.putStrLn =<< fmap (\currTime -> toLivePlayListString p $ realToFrac (currTime `diffUTCTime` t)) getCurrentTime
```
