module HLS.ReadList (readAndMergePlayListFiles) where

import Data.ByteString (ByteString)
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC
import System.Directory
import qualified Text.Regex.PCRE as R ((=~))

import HLS.PlayList

-- Auxiliary

(=~) :: ByteString -> ByteString -> [[ByteString]]
(=~) = (R.=~)

toRead :: Read a => ByteString -> a
toRead = read . BC.unpack

-- Real

readAndMergePlayListFiles :: FilePath -> IO PlayList
readAndMergePlayListFiles = fmap mergeList . readPlayListFiles

readPlayListFiles :: FilePath -> IO [PlayList]
readPlayListFiles fp = do
  dirs <- listDirectory $ "./static/" <> fp
  traverse (readPlayListFile fp) dirs

readPlayListFile :: FilePath -> FilePath -> IO PlayList
readPlayListFile fp dir = do
  str <- B.readFile $ "./static/" <> fp <> "/" <> dir <> "/playlist.m3u8"
  pure $ fromPlayListString fp dir str

fromPlayListString :: FilePath -> FilePath -> ByteString -> PlayList
fromPlayListString fp dir str = let ss = matchSegments fp dir str
  in PlayList (sum $ fmap segmentLength ss) (matchTargetDuration str) ss

matchTargetDuration :: ByteString -> Int
matchTargetDuration str = let ((_:dur:_):_) = str =~ "^#EXT-X-TARGETDURATION:(\\d+)$"
  in toRead dur

matchSegments :: FilePath -> FilePath -> ByteString -> [SegmentInfo]
matchSegments fp dir str = zipWith3 SegmentInfo [0..] ss (fmap ((BC.pack fp <> "/" <> BC.pack dir <> "/") <>) fs)
 where
  (ss, fs) = unzip $ fmap (\(_:extinf:_:file:_) -> (toRead extinf, file)) $ str =~ "^#EXTINF:(\\d+(\\.\\d+)?),\\n([^.]+\\.ts)$"

mergeList :: [PlayList] -> PlayList
mergeList xs = PlayList (sum $ fmap totalLength xs) (maximum $ fmap targetDuration xs) (concat $ fmap segments xs)
