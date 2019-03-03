module HLS.PlayList where

import Data.ByteString (ByteString)

data PlayList = PlayList
  { totalLength    :: Float
  , targetDuration :: Int
  , segments       :: [SegmentInfo]
  } deriving Show

data SegmentInfo = SegmentInfo
  { sequenceNum   :: Int
  , segmentLength :: Float
  , filePath      :: ByteString
  } deriving Show
