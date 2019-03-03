{-# LANGUAGE NamedFieldPuns #-}

module HLS.GenList (toLivePlayListString) where

import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as BC
import Data.Fixed (mod')
import Data.Monoid

import HLS.PlayList

-- Auxiliary

fromShow :: Show a => a -> ByteString
fromShow = BC.pack . show

mTakeUntil :: (Monoid b, Ord b) => b -> (a -> b) -> [a] -> [a]
mTakeUntil thre f xs = mTakeUntil_aux xs mempty
 where
  mTakeUntil_aux ys acc = if (f (head ys) <> acc) >= thre
    then []
    else head ys : mTakeUntil_aux (tail ys) (f (head ys) <> acc)

mDropUntil :: (Monoid b, Ord b) => b -> (a -> b) -> [a] -> [a]
mDropUntil thre f xs = mDropUntil_aux xs mempty
 where
  mDropUntil_aux ys acc = if (f (head ys) <> acc) >= thre
    then ys
    else mDropUntil_aux (tail ys) (f (head ys) <> acc)

-- Real

toLivePlayListString :: PlayList -> Float -> ByteString
toLivePlayListString p timestamp = let livePlayList = genLivePlayList p timestamp
  in toPlayListString livePlayList

genLivePlayList :: PlayList -> Float -> PlayList
genLivePlayList PlayList{totalLength,targetDuration,segments} timestamp =
  let timestamp'        = Sum $ timestamp `mod'` totalLength
      playListMinLength = Sum $ toEnum $ targetDuration * 8  -- Not smaller than 3
      toMonoid          = Sum . segmentLength
      segments'         = mTakeUntil playListMinLength toMonoid . mDropUntil timestamp' toMonoid $ cycle segments
   in PlayList undefined targetDuration segments'

toPlayListString :: PlayList -> ByteString
toPlayListString PlayList{targetDuration,segments} =
  let heading         = "#EXTM3U\n#EXT-X-VERSION:3\n"
      media_sequence  = "#EXT-X-MEDIA-SEQUENCE:" <> (fromShow $ sequenceNum $ head segments) <> "\n"
      targetDuration' = "#EXT-X-TARGETDURATION:" <> (fromShow $ targetDuration) <> "\n"
      segments'       = foldMap toSegmentInfoString segments
   in heading <> media_sequence <> targetDuration' <> segments'

toSegmentInfoString :: SegmentInfo -> ByteString
toSegmentInfoString s =
  let isStart        = if sequenceNum s == 0 then "#EXT-X-DISCONTINUITY\n" else mempty
      segmentLength' = "#EXTINF:" <> (fromShow $ segmentLength s) <> ",\n"
      filePath'      = filePath s <> "\n"
   in isStart <> segmentLength' <> filePath'
