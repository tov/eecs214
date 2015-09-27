#!/usr/bin/env runhaskell
{-# LANGUAGE OverloadedStrings, MultiWayIf #-}
{-# OPTIONS_GHC -fno-warn-unused-do-bind #-}

import Prelude hiding (abs, concatMap)

import qualified Data.ByteString as BS
import qualified Data.Array.IArray as Array
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import qualified Text.Blaze.Html.Renderer.Utf8 as B.R.Utf8
import qualified Text.Blaze.Html.Renderer.String as B.R.String
import qualified Text.Highlighting.Kate as Kate

import Control.Monad (when)
import Data.Foldable (toList, for_, concatMap)
import Data.List (transpose, intersperse)
import Data.Maybe (fromMaybe)
import Data.Monoid
import Text.Blaze.Html5 ((!))
import Text.Printf (printf)

main :: IO ()
main = B.R.Utf8.renderHtmlToByteStringIO BS.putStr document

term :: H.Html
term  = "EECS 214, Fall 2015"

document :: H.Html
document = slideShow "The Random Access Machine" $ do
        titleSlide "Some definitions" $ do
          codeBlock "java" $ unlines
            [ "// Java"
            , "class Posn { int x, y; }" ]
          codeBlock "c" $ unlines
            [ "/* C, C++ */"
            , "struct PosnStruct { int x, y; }"
            , "typedef struct PosnStruct* Posn"
            ]
          codeBlock "ruby" $ unlines
            [ "# Ruby"
            , "Posn = Struct.new('Posn', :x, :y)"
            ]
          codeBlock "python" $ unlines
            [ "# Python"
            , "from collections import namedtuple"
            , "Posn = namedtuple('Posn', 'x y')"
            ]

        imageSlide "images/Mem01Arrows.svg"
        imageSlide "images/Mem02Bits.svg"
        imageSlide "images/Mem03Octets.svg"
        imageSlide "images/Mem04SplitWords.svg"
        imageSlide "images/Mem05ThreeWords.svg"
        imageSlide "images/Mem06Int8.svg"
        imageSlide "images/Mem07Ascii.svg"
        imageSlide "images/Mem08Ucs2.svg"
        imageSlide "images/Mem09Integers.svg"
        imageSlide "images/Mem10Pointers.svg"
        -- imageSlide "images/Mem11Mixed.svg"
        imageSlide "images/Mem01Arrows.svg"

        let table0 = newMemory 0x800 48
        let mkTable1 lab = setMemory
                [ int 32        @. lab "int a"
                , int 32 @# 2   @. lab "long b"
                , ptr 0x0860    @. lab "Posn c"
                , ptr 0         @. lab "Posn d"
                , ptr 0x0840    @. lab "int[] e"
                , ptr 0x0888    @. lab "Posn[] f"

                , hdr "int[].class" @@ 0x0840
                , int 5
                , int 1
                , int 4
                , int 9
                , int 16
                , int 49

                , hdr "Posn.class" @@ 0x0860
                , int 3
                , int 4

                , hdr "Posn.class" @@ 0x0870
                , int 5
                , int 12

                , hdr "Posn[].class" @@ 0x0888
                , int 4
                , ptr 0x0860
                , ptr 0
                , ptr 0x0870
                , ptr 0x0870

                ]
              table0

        let table1 = mkTable1 noLabel
        let table2 = mkTable1 label

        slide $ memoryTable 12 table1

        slide $ memoryTable 12 table2

        let code1slide table = slide $ do
              memoryTable 12 table
              codeFloat "java" "d = new Posn(-12, 78);"

        code1slide table2

        let table3 = setMemory
              (map (@! A.class_ "freeList")
                [ ptr 0x0830 @@ 0x0880
                , int 8
                , ptr 0x08a0 @@ 0x0830
                , int 16
                , ptr 0x0    @@ 0x08a0
                , int 32
                , ptr 0x0880 @@ 0x082c @. label "freeList"
                ])
              table2
        code1slide table3

        let table4 = setMemory
                [ ptr 0x08a0 @@ 0x880 @! A.class_ "freeList"
                , hdr "Posn.class" @@ 0x0830
                , int 12
                , int (-78)
                ]
              table3
        code1slide table4

        let table5 = setMemory
                [ ptr 0x0830 @@ 0x810 @. label "Posn d" ]
              table4
        code1slide table5

        let stack1 = newMemory 0x8000 8
        let heap1  = newMemory 0x2000 24

        let stackHeapSlide stack heap after = slide $ do
              H.table $ do
                H.tr $ do
                  H.td $ memoryTable' True 8 stack
                  H.td $ memoryTable' False 8 heap
                H.tr $ do
                  H.th $ "the stack"
                  H.th $ "the heap"
                H.tr $ do
                  H.td ! A.colspan "2" $ after

        titleSlide "More definitions" $ do
          codeBlock "java" $ unlines
            [ "// Java"
            , "class Cons { int hd; Cons tl; }" ]
          codeBlock "c" $ unlines
            [ "/* C, C++ */"
            , "struct Node { int hd; Node* tl; }"
            , "typedef struct Node* Cons"
            ]
          codeBlock "ruby" $ unlines
            [ "# Ruby"
            , "Cons = Struct.new('Cons', :hd, :tl)"
            ]
          codeBlock "python" $ unlines
            [ "# Python"
            , "from collections import namedtuple"
            , "Cons = namedtuple('Cons', 'hd tl')"
            ]

        let iotaR1 = unlines
              [ "def iotaR(n):"
              , "  if n < 1: return None"
              , "  else:     return Cons(n - 1, iotaR(n - 1))" ]

        stackHeapSlide stack1 heap1 $ codeBlock "python" iotaR1

        let iotaR2 = iotaR1 ++ "\nlst = iotaR(3)"

        stackHeapSlide stack1 heap1 $ codeBlock "python" iotaR2

        let stack2 = setMemory
                       [ ptr 0x1128 @. label "lst=•"
                       , int 3      @. label "int n" ]
                       stack1
        stackHeapSlide stack2 heap1 $ codeBlock "python" iotaR2

        let stack3 = setMemory
                       [ ptr 0x12a0 @@ 0x8008  @. label "Cons(2,•)"
                       , int 2 @. label "int n" ]
                       stack2
        stackHeapSlide stack3 heap1 $ codeBlock "python" iotaR2

        let stack4 = setMemory
                       [ ptr 0x12a0 @@ 0x8010  @. label "Cons(1,•)"
                       , int 1 @. label "int n" ]
                       stack3
        stackHeapSlide stack4 heap1 $ codeBlock "python" iotaR2

        let stack5 = setMemory
                       [ ptr 0x12a0 @@ 0x8018  @. label "Cons(0,•)"
                       , int 0 @. label "int n" ]
                       stack4
        stackHeapSlide stack5 heap1 $ codeBlock "python" iotaR2

        let heap6  = setMemory [ hdr "None" ] heap1
        stackHeapSlide stack5 heap6 $ codeBlock "python" iotaR2

        let stack6 = setMemory
                       [ ptr 0x2000 @@ 0x801C  @. label "result" ]
                       stack5
        stackHeapSlide stack6 heap6 $ codeBlock "python" iotaR2

        let heap7  = setMemory
                       [ hdr "Cons" @@ 0x2008
                       , int 0
                       , ptr 0x2000 ] heap6
        stackHeapSlide stack6 heap7 $ codeBlock "python" iotaR2

        let stack7 = setMemory
                       [ ptr 0x2008 @@ 0x8014  @. label "result"
                       , cell mempty
                       , cell mempty ]
                       stack6
        stackHeapSlide stack7 heap7 $ codeBlock "python" iotaR2

        let heap8  = setMemory
                       [ hdr "Cons" @@ 0x2018
                       , int 1
                       , ptr 0x2008 ] heap7
        stackHeapSlide stack7 heap8 $ codeBlock "python" iotaR2

        let stack8 = setMemory
                       [ ptr 0x2018 @@ 0x800C  @. label "result"
                       , cell mempty
                       , cell mempty ]
                       stack7
        stackHeapSlide stack8 heap8 $ codeBlock "python" iotaR2

        let heap9  = setMemory
                       [ hdr "Cons" @@ 0x2028
                       , int 2
                       , ptr 0x2018 ] heap8
        stackHeapSlide stack8 heap9 $ codeBlock "python" iotaR2

        let stack9 = setMemory
                       [ ptr 0x2028 @@ 0x8004  @. label "result"
                       , cell mempty
                       , cell mempty ]
                       stack8
        stackHeapSlide stack9 heap9 $ codeBlock "python" iotaR2

        let stack10 = setMemory
                       [ ptr 0x2028 @. label "lst"
                       , cell mempty ]
                       stack9
        stackHeapSlide stack10 heap9 $ codeBlock "python" iotaR2

        let sum1 = unlines
              [ "def sum(lst):"
              , "  total = 0"
              , "  while lst != None:"
              , "    (total, lst) = (total + lst.hd, lst tl)"
              , "  return total" ]

        stackHeapSlide stack10 heap9 $ codeBlock "python" sum1

        let stack11 = setMemory
                        [ hdr "RA" @@ 0x8004
                        , ptr 0x2028 @. label "lst"
                        ]
                        stack10
        stackHeapSlide stack11 heap9 $ codeBlock "python" sum1

        stackHeapSlide
          (setMemory [ int 0 @@ 0x800C @. label "total" ] stack11)
          heap9
          (codeBlock "python" sum1)

        stackHeapSlide
          (setMemory [ int 2 @@ 0x800C @. label "total" ] stack11)
          heap9
          (codeBlock "python" sum1)

        stackHeapSlide
          (setMemory [ ptr 0x2018 @@ 0x8008 @. label "lst"
                     , int 2 @@ 0x800C @. label "total" ] stack11)
          heap9
          (codeBlock "python" sum1)

        stackHeapSlide
          (setMemory [ ptr 0x2018 @@ 0x8008 @. label "lst"
                     , int 3 @@ 0x800C @. label "total" ] stack11)
          heap9
          (codeBlock "python" sum1)

        stackHeapSlide
          (setMemory [ ptr 0x2008 @@ 0x8008 @. label "lst"
                     , int 3 @@ 0x800C @. label "total" ] stack11)
          heap9
          (codeBlock "python" sum1)

        stackHeapSlide
          (setMemory [ ptr 0x2008 @@ 0x8008 @. label "lst"
                     , int 3 @@ 0x800C @. label "total" ] stack11)
          heap9
          (codeBlock "python" sum1)

        stackHeapSlide
          (setMemory [ ptr 0x2000 @@ 0x8008 @. label "lst"
                     , int 3 @@ 0x800C @. label "total" ] stack11)
          heap9
          (codeBlock "python" sum1)

        let stack12 = setMemory [ int 0 @@ 0x800C @. label "total" ] stack11

        sectionSlide "Lies!"

        let rshSlide regs stack heap = slide $ do
              registerTable regs
              H.table $ do
                H.tr $ do
                  H.td $ memoryTable' True 8 stack
                  H.td $ memoryTable' False 8 heap
                H.tr $ do
                  H.th $ "the stack"
                  H.th $ "the heap"

        let rshSequence :: Memory -> Memory -> Memory ->
                           [[Block]] -> H.Html
            rshSequence regs0 stack heap steps =
              for_ (scanl (flip setMemory) regs0 steps) $
                \regs -> rshSlide regs stack heap

        let sumSequence =
              [ a [ ptr 0x8010        @. label "SP" ]
              , a [ ptr 0x800C  @@  4 @. label "&total" ]
              , m [ int 0       @@  4 @. label "total"       ]
              , a [ ptr 0x8008  @@  8 @. label "&xs"         ]
              , m [ ptr 0x2028  @@  8 @. label "xs"          ]
              --
              , a [ ptr 0x202c  @@ 12 @. label xsFirst       ]
              , m [ int 2       @@ 12 @. label "xs.hd"    ]
              , a [ int 2       @@  4 @. label "total" ]
              , a [ ptr 0x2030  @@  8 @. label xsRest ]
              , m [ ptr 0x2018  @@  8 @. label "xs.tl" ]
              ,   [ ptr 0x2018  @@  8 @. label "xs"
                  , int 2       @@ 12 ]
              --
              , a [ ptr 0x201c  @@ 12 @. label xsFirst ]
              , m [ int 1       @@ 12 @. label "xs.hd" ]
              , a [ int 3       @@  4 @. label "total" ]
              , a [ ptr 0x2020  @@  8 @. label xsRest ]
              , m [ ptr 0x2008  @@  8 @. label "xs.tl" ]
              ,   [ ptr 0x2008  @@  8 @. label "xs"
                  , int 1       @@ 12 ]
              --
              , a [ ptr 0x200c  @@ 12 @. label xsFirst ]
              , m [ int 0       @@ 12 @. label "xs.hd" ]
              , a [ int 3       @@  4 @. label "total" ]
              , a [ ptr 0x2010  @@  8 @. label xsRest ]
              , m [ ptr 0x2000  @@  8 @. label "xs.tl" ]
              ,   [ ptr 0x2000  @@  8 @. label "xs"
                  , int 0       @@ 12 ]
              ] where
                xsFirst :: H.Html
                xsFirst  = "&xs." >> "hd"
                xsRest  :: H.Html
                xsRest   = "&xs." >> "tl"
                m = id
                a = id

        let regs0 = newMemory 0 4
        rshSequence regs0 stack12 heap9 sumSequence

        let regs1   = foldl (flip setMemory) regs0 sumSequence
        let stack13 = setMemory [int 3 @@ 0x800c @. label "total"] stack12
        rshSlide regs1 stack13 heap9

        let switch :: Bool -> H.Html -> H.Html -> H.Html
            switch True  true _     = H.span true
            switch False true false =
              H.span ! A.style "position: relative;" $ do
                H.span true ! showWhen False
                H.span false ! A.style "position: absolute; right: 0; top: 0;"

        for_ [0 .. 5] $ \step ->
          slide $ do
            H.table $ do
              H.thead . H.tr $ do
                H.th mempty
                H.th $ switch (step < 5) "Arithmetic" "Registers"
                H.th $ switch (step < 5) "Memory"     "DRAM"
              H.tbody $ do
                H.tr !. "right" $ do
                  H.th "No. of instructions"
                  H.td "12"
                  H.td "8"
                H.tr ! showWhen (step >= 1)
                     !. "right"     $ do
                  H.th "Cycles per operation"
                  H.td .
                    apWhen (step >= 3) (!. "arithbar") .
                      H.span $ do
                        when (step >= 3) "× "
                        "1"
                  H.td .
                    apWhen (step >= 3) (!. "arithbar") .
                      H.span $ do
                    (if step >= 3 then ("× " >>) else H.strong) $
                      if step >= 2 then "100" else "?"
                H.tr ! showWhen (step >= 3)
                     !. "right"     $ do
                  H.th "Total CPU cycles"
                  H.td "12"
                  H.td "800"
                H.tr ! showWhen (step >= 4)
                     !. "right"     $ do
                  H.th "Percent of time"
                  H.td $ H.em !. "color" $ "1.5%"
                  H.td $ H.em !. "color" $ "98.5%"
            H.div ! showWhen (step `elem` [1..2])
                  !. "bottom-message" $ do
              "The cycle time (period) is the reciprocal of the "
              "clock speed (frequency). For a 2.5 GHz CPU, for example, "
              "the cycle time is "
              math $ "1 / (2.5 \\times 10^9)"
                  ++ " = 0.4\\mathop{\\mathrm{ns}}"
                  ++ " = 0.0000000004\\mathop{\\mathrm{s}}."

        for_ [0 :: Int .. 10] $ \step ->
          titleSlide "The memory hierarchy" $ do
            apWhen (step >= 10) (! A.style "font-size: 85%;") $ do
              H.table $ do
                H.thead $ do
                  H.tr ! showWhen (step >=5) $ do
                    H.th mempty
                    H.th mempty
                    H.th ! A.style "border-bottom: 3px dotted;"
                         ! A.colspan (H.toValue ((step - 4) `min` 3))
                         $ "Cache"
                  H.tr $ do
                    H.th mempty
                    H.th "Registers"
                    when (step `elem` [1..4]) $ H.th "Cache"
                    when (step >= 5) $ H.th "L1"
                    when (step >= 6) $ H.th "L2"
                    when (step >= 7) $ H.th "L3"
                    H.th "DRAM"
                    when (step >= 10) $ H.th "Disk"
                H.tbody $ do
                  H.tr !. "right" $ do
                    H.th "Latency (cycles)"
                    H.td "1"
                    when (step `elem` [1..4]) $ H.td "10"
                    when (step >= 5) $ H.td "2"
                    when (step >= 6) $ H.td "10"
                    when (step >= 7) $ H.td "40"
                    H.td "100"
                    when (step >= 10) $ H.td "2500"
                  H.tr !. "right" $ do
                    H.th "Latency (ns)"
                    H.td "0.4"
                    when (step `elem` [1..4]) $ H.td "4"
                    when (step >= 5) $ H.td "0.8"
                    when (step >= 6) $ H.td "4"
                    when (step >= 7) $ H.td "16"
                    H.td "40"
                    when (step >= 10) $ H.td "1000"
                  H.tr ! showWhen (step >= 4)
                       !. "right" $ do
                    H.th "Price (US$/GiB)"
                    H.td $ H.em !. "color" $ "priceless"
                    when (step `elem` [1..4]) $ H.td $ H.strong "?"
                    when (step >= 5) $ H.td $ H.em !. "color" $ "n.f.s."
                    when (step >= 6) $ H.td $ H.em !. "color" $ "n.f.s."
                    when (step >= 7) $ H.td "$2500"
                    H.td "$50"
                    when (step >= 10) $ H.td "$0.10"
                  H.tr ! showWhen (step >= 8)
                       !. "right" $ do
                    H.th "Typical size"
                    H.td $ "128 B"
                    H.td $ "128 KiB"
                    H.td $ "1 MiB"
                    H.td $ "6 MiB"
                    H.td $ "16 GiB"
                    when (step >= 10) $ H.td "1 TiB"
                  H.tr ! showWhen (step >= 9)
                       !. "right" $ do
                    H.th $ math "2^k" >> " bytes"
                    H.td $ math "7"
                    H.td $ math "17"
                    H.td $ math "20"
                    H.td $ math "22.6"
                    H.td $ math "34"
                    when (step >= 10) $ H.td "40"
              H.div ! showWhen (step `elem` [2..3])
                    !. "bottom-message" $ do
                H.h4 !. "center" $ do
                        "Average length of load or"
                        H.br
                        "store (in clock cycles)"
                H.dl $ do
                  H.dt "Without cache:"
                  H.dd "100"
                  H.dt "With cache (assuming 90% hit rate):"
                  H.dd ! showWhen (step `elem` [3..3]) $ do
                    math ".9 × 10 + .1 × 100 = 19"

        titleSlide "How to win big" $ do
          "Don’t take cache misses."

        titleSlide "How to win big" $ do
          "Don’t take cache misses."
          H.h3 "Okay, but how?"
          "Locality!"

        for_ [0..1] $ \step -> do
          titleSlide "Memory locality" $ do
            H.dl $ do
              H.dt . H.p $ do
                "Time locality:"
              H.dd . H.p $ do
                "You are likely to access things "
                "you’ve accessed recently."
              H.dt . H.p $ do
                "Space locality:"
              H.dd . H.p $ do
                "You are likely to access things "
                H.em !. "color" $ "near things "
                "you’ve accessed recently."
            H.div ! showWhen (step >= 1) $ do
              H.h4 "Caching takes advantage of both:"
              H.ul $ do
                H.li . H.p $ do
                  "Once an item is in cache, "
                  "it’s ready to be accessed again." 
                H.li . H.p $ do
                  "Each cache line holds a block of words, "
                  "which means when an item is in cache, "
                  "so are its closest neighbors."

        for_ [0..2] $ \step -> do
          titleSlide "Data structure strategies" $ do
            H.ol $ do
              H.li . H.p $ "Chunking"
              H.li . H.p $ "Cache obliviousness"
              H.li . H.p $ "Don’t worry, be happy"
            H.p "Our analyses will usually ignore cache"

        return ()

elt !. attr = elt ! A.class_ attr

titleSlide :: H.Html -> H.Html -> H.Html
titleSlide title body =
  slide $ do
    H.h1 title
    body

showWhen :: Bool -> H.Attribute
showWhen True  = A.style "visibility: visible;"
showWhen False = A.style "visibility: hidden;"

apWhen :: Bool -> (a -> a) -> a -> a
apWhen True  = id
apWhen False = const id

math   :: String -> H.Html
math s  = H.span !. "math inline" $ do
            "\\("
            H.toHtml s
            "\\)"

slide :: H.Html -> H.Html
slide body =
  H.section !. "slide level2" $ body

imageSlide :: H.AttributeValue -> H.Html
imageSlide  = slide . fullImage

fullImage :: H.AttributeValue -> H.Html
fullImage url = H.p $ H.img ! A.src url !. "fullpicture"

sectionSlide :: H.Html -> H.Html
sectionSlide title =
  H.section !. "slide level1 titleslide" $ H.h1 title

regTable :: [Block] -> H.Html
regTable  = registerTable . regFile

regFile :: [Block] -> Memory
regFile blocks = blocks `setMemory` newMemory 0 (length blocks)

registerTable :: Memory -> H.Html
registerTable regs = do
  let width = arrayLength (memValues regs)
  H.table !. "memory registers" $ do
    H.thead . H.tr $
      for_ [0 .. width - 1] $
        H.th . H.toHtml . ('R' :) . show
    H.tbody . H.tr $
      for_ (memValues regs) $ \(n, v, fv) ->
        fv (H.td (if n == 0 then nbsp else v))
    H.tfoot . H.tr $
      H.th ! A.colspan (H.toValue width) $
        "the register file"

arrayLength :: (Array.IArray a e, Array.Ix i) => a i e -> Int
arrayLength  = Array.rangeSize . Array.bounds

memoryTable :: Int -> Memory -> H.Html
memoryTable  = memoryTable' True

memoryTable' :: Bool -> Int -> Memory -> H.Html
memoryTable' labelRows height memory = do
  H.table !. "memory" $ do
    H.thead $ H.tr . mconcat $ columnLabels
    H.tbody $ mapM_ (H.tr . mconcat) rows
  where
    columnLabels  = if labelRows
                      then H.th mempty : nonEmptyColumnLabels
                      else nonEmptyColumnLabels
    nonEmptyColumnLabels
                  = [ H.th . H.code . H.toHtml $
                        (printf "0x%04x" offset :: String)
                    | offset <- columnOffsets ]
    columnOffsets = [ memAddress memory + 4 * height * offset
                    | offset <- [ 0 .. length columns - 1 ] ]
    --
    rows = transpose (if labelRows then rowLabels : columns else columns)
    rowLabels  = [ H.th $ do
                     "+"
                     H.code (H.toHtml (printf "%02x" offset :: String))
                 | offset <- rowOffsets ]
    rowOffsets = map (4 *) [ 0 .. height - 1 ]
    --
    columns = makeColumns (toList (memValues memory))
    makeColumns []    = []
    makeColumns cells =
      let first = fixRowspans (take height cells)
          rest  = makeColumns (drop height cells)
       in first : rest
    --
    fixRowspans [] = []
    fixRowspans ((0, _, finish) : rest) =
      finish (H.td nbsp)
        : fixRowspans rest
    fixRowspans ((n, content, finish) : rest) = do
      (finish (H.td ! A.rowspan (H.stringValue (show n)) $ content))
        : replicate (n - 1) mempty
        ++ fixRowspans (drop (n - 1) rest)

type Address = Int

data Memory = Memory {
  memAddress :: !Address,
  memValues  :: !(Array.Array Int (Int, H.Html, H.Html -> H.Html))
}

newMemory :: Address -> Int -> Memory
newMemory start size = Memory {
  memAddress = start,
  memValues  = Array.array (0, size - 1)
                           [(ix, (0, mempty, id)) | ix <- [0 .. size - 1]]
}

data Block = Block {
  blMAddr   :: !(Maybe Address),
  blSize    :: !Int,
  blContent :: !H.Html,
  blFinish  :: !(H.Html -> H.Html)
}

setMemory :: [Block] -> Memory -> Memory
setMemory blocks0 memory0 = loop (memAddress memory0) blocks0 memory0
  where
    loop _      []     = id
    loop offset (Block maddress size content finish : rest)
                       = let addr = fromMaybe offset maddress
                          in setMemory1 addr size content finish
                               . loop (addr + 4 * size) rest



(@@) :: Block -> Address -> Block
block @@ address = block { blMAddr = Just address }

(@#) :: Block -> Int -> Block
block @# size = block { blSize = size }

(@.) :: Block -> (H.Html -> H.Html) -> Block
block @. trans = block { blContent = trans (blContent block) }

(@$) :: Block -> (H.Html -> H.Html) -> Block
block @$ finish = block { blFinish = finish . blFinish block }

(@!) :: Block -> H.Attribute -> Block
block @! attr = block @$ (! attr)

cell  :: H.Html -> Block
cell content = Block Nothing 1 content id

hdr  :: H.Html -> Block
hdr s = cell s @! A.class_ "obj-header"

ptr  :: Int -> Block
ptr z = cell (H.code (H.toHtml (printf "0x%04x" z :: String)))

int  :: Int -> Block
int z = cell (H.toHtml (printf "%d" z :: String))

noLabel :: H.Html -> H.Html -> H.Html
noLabel  = const id

label :: H.Html -> H.Html -> H.Html
label lab subject = do
  H.code !. "label" $ lab
  subject

setMemory1 :: Address -> Int -> H.Html -> (H.Html -> H.Html) ->
              Memory -> Memory
setMemory1 address words content finish memory =
  let byteOffset              = address - memAddress memory
      (wordOffset, wordAlign) = byteOffset `divMod` 4 in
  if wordAlign /= 0
    then error "setMemory: unaligned offset"
    else memory { memValues = memValues memory Array.//
                    take words ((wordOffset, (words, content, finish))
                                :
                                [ (index, (0, mempty, id))
                                | index <- [ wordOffset + 1 .. ] ]) }

instance Show Memory where
  show memory = printf "Memory { %04x -> %s}"
                  (memAddress memory)
                  (concatMap handle (memValues memory))
    where handle (ix, elt, _) = B.R.String.renderHtml elt ++ ", "

codeFloat :: String -> String -> H.Html
codeFloat lang code = H.div !. "code message" $ codeBlock lang code

codeBlock :: String -> String -> H.Html
codeBlock lang code =
  Kate.formatHtmlBlock Kate.defaultFormatOpts $
    Kate.highlightAs lang code

codeInline :: String -> String -> H.Html
codeInline lang code =
  H.span !. "code inline" $
    Kate.formatHtmlInline Kate.defaultFormatOpts $
      Kate.highlightAs lang code

nbsp :: H.Html
nbsp = H.preEscapedToHtml ("&nbsp;" :: String)

loadMathJax :: H.Html
loadMathJax = H.script
  ! A.src (H.toValue mathJaxUrl)
  ! A.type_ "text/javascript"
    $ mempty

mathJaxUrl :: String
mathJaxUrl  = "https://cdn.mathjax.org/mathjax/latest/MathJax.js"
                ++ "?config=TeX-AMS_HTML"

slideShow :: String -> H.Html -> H.Html
slideShow title body = H.docTypeHtml $ do
    H.head $ do
        H.meta ! A.charset "utf-8"
        H.title $ H.toHtml title
        H.link ! A.rel "stylesheet" ! A.href "slides.css"
        loadMathJax
    H.body $ do
        H.section !. "title" $ do
            H.h1 !. "title" $ H.toHtml title
            H.h3 !. "date" $ term
        body

        --  {{{{ dzslides core
        -- #
        -- #
        -- #     __  __  __       .  __   ___  __
        -- #    |  \  / /__` |    | |  \ |__  /__`
        -- #    |__/ /_ .__/ |___ | |__/ |___ .__/ core :€
        -- #
        -- #
        -- # The following block of H.code is not supposed to be edited.
        -- # But if you want to change the behavior of these slides,
        -- # feel free to hack it!
        -- #
        H.div ! A.id "progress-bar" $ mempty
        --  Default Style 
        H.style "* { margin: 0; padding: 0; -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box; }\n  details { display: none; }\n  body {\n    width: 800px; height: 600px;\n    margin-left: -400px; margin-top: -300px;\n    position: absolute; top: 50%; left: 50%;\n    overflow: hidden;\n  }\n  section {\n    position: absolute;\n    pointer-events: none;\n    width: 100%; height: 100%;\n  }\n  section[aria-selected] { pointer-events: auto; }\n  html { overflow: hidden; }\n  body { display: none; }\n  body.loaded { display: block; }\n  .incremental {visibility: hidden; }\n  .incremental[active] {visibility: visible; }\n  #progress-bar{\n    bottom: 0;\n    position: absolute;\n    -moz-transition: width 400ms linear 0s;\n    -webkit-transition: width 400ms linear 0s;\n    -ms-transition: width 400ms linear 0s;\n    transition: width 400ms linear 0s;\n  }\n  figure {\n    width: 100%;\n    height: 100%;\n  }\n  figure > * {\n    position: absolute;\n  }\n  figure > img, figure > video {\n    width: 100%; height: 100%;\n  }"
        H.script "var Dz = {\n    remoteWindows: [],\n    idx: -1,\n    step: 0,\n    slides: null,\n    progressBar : null,\n    params: {\n      autoplay: \"1\"\n    }\n  };\n\n  Dz.init = function() {\n    document.body.className = \"loaded\";\n    this.slides = $$(\"body > section\");\n    this.progressBar = $(\"#progress-bar\");\n    this.setupParams();\n    this.onhashchange();\n    this.setupTouchEvents();\n    this.onresize();\n  }\n  \n  Dz.setupParams = function() {\n    var p = window.location.search.substr(1).split('&');\n    p.forEach(function(e, i, a) {\n      var keyVal = e.split('=');\n      Dz.params[keyVal[0]] = decodeURIComponent(keyVal[1]);\n    });\n  // Specific params handling\n    if (!+this.params.autoplay)\n      $$.forEach($$(\"video\"), function(v){ v.controls = true });\n  }\n\n  Dz.onkeydown = function(aEvent) {\n    // Don’t intercept keyboard shortcuts\n    if (aEvent.altKey\n      || aEvent.ctrlKey\n      || aEvent.metaKey\n      || aEvent.shiftKey) {\n      return;\n    }\n    if ( aEvent.keyCode == 37 // left arrow\n      || aEvent.keyCode == 38 // up arrow\n      || aEvent.keyCode == 33 // page up\n    ) {\n      aEvent.preventDefault();\n      this.back();\n    }\n    if ( aEvent.keyCode == 39 // right arrow\n      || aEvent.keyCode == 40 // down arrow\n      || aEvent.keyCode == 34 // page down\n    ) {\n      aEvent.preventDefault();\n      this.forward();\n    }\n    if (aEvent.keyCode == 35) { // end\n      aEvent.preventDefault();\n      this.goEnd();\n    }\n    if (aEvent.keyCode == 36) { // home\n      aEvent.preventDefault();\n      this.goStart();\n    }\n    if (aEvent.keyCode == 32) { // space\n      aEvent.preventDefault();\n      this.toggleContent();\n    }\n    if (aEvent.keyCode == 70) { // f\n      aEvent.preventDefault();\n      this.goFullscreen();\n    }\n  }\n\n  /* Touch Events */\n\n  Dz.setupTouchEvents = function() {\n    var orgX, newX;\n    var tracking = false;\n\n    var db = document.body;\n    db.addEventListener(\"touchstart\", start.bind(this), false);\n    db.addEventListener(\"touchmove\", move.bind(this), false);\n\n    function start(aEvent) {\n      aEvent.preventDefault();\n      tracking = true;\n      orgX = aEvent.changedTouches[0].pageX;\n    }\n\n    function move(aEvent) {\n      if (!tracking) return;\n      newX = aEvent.changedTouches[0].pageX;\n      if (orgX - newX > 100) {\n        tracking = false;\n        this.forward();\n      } else {\n        if (orgX - newX < -100) {\n          tracking = false;\n          this.back();\n        }\n      }\n    }\n  }\n\n  /* Adapt the size of the slides to the window */\n\n  Dz.onresize = function() {\n    var db = document.body;\n    var sx = db.clientWidth / window.innerWidth;\n    var sy = db.clientHeight / window.innerHeight;\n    var transform = \"scale(\" + (1/Math.max(sx, sy)) + \")\";\n\n    db.style.MozTransform = transform;\n    db.style.WebkitTransform = transform;\n    db.style.OTransform = transform;\n    db.style.msTransform = transform;\n    db.style.transform = transform;\n  }\n\n\n  Dz.getDetails = function(aIdx) {\n    var s = $(\"section:nth-of-type(\" + aIdx + \")\");\n    var d = s.$(\"details\");\n    return d ? d.innerHTML : \"\";\n  }\n\n  Dz.onmessage = function(aEvent) {\n    var argv = aEvent.data.split(\" \"), argc = argv.length;\n    argv.forEach(function(e, i, a) { a[i] = decodeURIComponent(e) });\n    var win = aEvent.source;\n    if (argv[0] === \"REGISTER\" && argc === 1) {\n      this.remoteWindows.push(win);\n      this.postMsg(win, \"REGISTERED\", document.title, this.slides.length);\n      this.postMsg(win, \"CURSOR\", this.idx + \".\" + this.step);\n      return;\n    }\n    if (argv[0] === \"BACK\" && argc === 1)\n      this.back();\n    if (argv[0] === \"FORWARD\" && argc === 1)\n      this.forward();\n    if (argv[0] === \"START\" && argc === 1)\n      this.goStart();\n    if (argv[0] === \"END\" && argc === 1)\n      this.goEnd();\n    if (argv[0] === \"TOGGLE_CONTENT\" && argc === 1)\n      this.toggleContent();\n    if (argv[0] === \"SET_CURSOR\" && argc === 2)\n      window.location.hash = \"#\" + argv[1];\n    if (argv[0] === \"GET_CURSOR\" && argc === 1)\n      this.postMsg(win, \"CURSOR\", this.idx + \".\" + this.step);\n    if (argv[0] === \"GET_NOTES\" && argc === 1)\n      this.postMsg(win, \"NOTES\", this.getDetails(this.idx));\n  }\n\n  Dz.toggleContent = function() {\n    // If a Video is present in this new slide, play it.\n    // If a Video is present in the previous slide, stop it.\n    var s = $(\"section[aria-selected]\");\n    if (s) {\n      var video = s.$(\"video\");\n      if (video) {\n        if (video.ended || video.paused) {\n          video.play();\n        } else {\n          video.pause();\n        }\n      }\n    }\n  }\n\n  Dz.setCursor = function(aIdx, aStep) {\n    // If the user change the slide number in the URL bar, jump\n    // to this slide.\n    aStep = (aStep != 0 && typeof aStep !== \"undefined\") ? \".\" + aStep : \".0\";\n    window.location.hash = \"#\" + aIdx + aStep;\n  }\n\n  Dz.onhashchange = function() {\n    var cursor = window.location.hash.split(\"#\"),\n        newidx = 1,\n        newstep = 0;\n    if (cursor.length == 2) {\n      newidx = ~~cursor[1].split(\".\")[0];\n      newstep = ~~cursor[1].split(\".\")[1];\n      if (newstep > Dz.slides[newidx - 1].$$('.incremental > *').length) {\n        newstep = 0;\n        newidx++;\n      }\n    }\n    this.setProgress(newidx, newstep);\n    if (newidx != this.idx) {\n      this.setSlide(newidx);\n    }\n    if (newstep != this.step) {\n      this.setIncremental(newstep);\n    }\n    for (var i = 0; i < this.remoteWindows.length; i++) {\n      this.postMsg(this.remoteWindows[i], \"CURSOR\", this.idx + \".\" + this.step);\n    }\n  }\n\n  Dz.back = function() {\n    if (this.idx == 1 && this.step == 0) {\n      return;\n    }\n    if (this.step == 0) {\n      this.setCursor(this.idx - 1,\n                     this.slides[this.idx - 2].$$('.incremental > *').length);\n    } else {\n      this.setCursor(this.idx, this.step - 1);\n    }\n  }\n\n  Dz.forward = function() {\n    if (this.idx >= this.slides.length &&\n        this.step >= this.slides[this.idx - 1].$$('.incremental > *').length) {\n        return;\n    }\n    if (this.step >= this.slides[this.idx - 1].$$('.incremental > *').length) {\n      this.setCursor(this.idx + 1, 0);\n    } else {\n      this.setCursor(this.idx, this.step + 1);\n    }\n  }\n\n  Dz.goStart = function() {\n    this.setCursor(1, 0);\n  }\n\n  Dz.goEnd = function() {\n    var lastIdx = this.slides.length;\n    var lastStep = this.slides[lastIdx - 1].$$('.incremental > *').length;\n    this.setCursor(lastIdx, lastStep);\n  }\n\n  Dz.setSlide = function(aIdx) {\n    this.idx = aIdx;\n    var old = $(\"section[aria-selected]\");\n    var next = $(\"section:nth-of-type(\"+ this.idx +\")\");\n    if (old) {\n      old.removeAttribute(\"aria-selected\");\n      var video = old.$(\"video\");\n      if (video) {\n        video.pause();\n      }\n    }\n    if (next) {\n      next.setAttribute(\"aria-selected\", \"true\");\n      var video = next.$(\"video\");\n      if (video && !!+this.params.autoplay) {\n        video.play();\n      }\n    } else {\n      // That should not happen\n      this.idx = -1;\n      // console.warn(\"Slide doesn't exist.\");\n    }\n  }\n\n  Dz.setIncremental = function(aStep) {\n    this.step = aStep;\n    var old = this.slides[this.idx - 1].$('.incremental > *[aria-selected]');\n    if (old) {\n      old.removeAttribute('aria-selected');\n    }\n    var incrementals = $$('.incremental');\n    if (this.step <= 0) {\n      $$.forEach(incrementals, function(aNode) {\n        aNode.removeAttribute('active');\n      });\n      return;\n    }\n    var next = this.slides[this.idx - 1].$$('.incremental > *')[this.step - 1];\n    if (next) {\n      next.setAttribute('aria-selected', true);\n      next.parentNode.setAttribute('active', true);\n      var found = false;\n      $$.forEach(incrementals, function(aNode) {\n        if (aNode != next.parentNode)\n          if (found)\n            aNode.removeAttribute('active');\n          else\n            aNode.setAttribute('active', true);\n        else\n          found = true;\n      });\n    } else {\n      setCursor(this.idx, 0);\n    }\n    return next;\n  }\n\n  Dz.goFullscreen = function() {\n    var html = $('html'),\n        requestFullscreen = html.requestFullscreen || html.requestFullScreen || html.mozRequestFullScreen || html.webkitRequestFullScreen;\n    if (requestFullscreen) {\n      requestFullscreen.apply(html);\n    }\n  }\n  \n  Dz.setProgress = function(aIdx, aStep) {\n    var slide = $(\"section:nth-of-type(\"+ aIdx +\")\");\n    if (!slide)\n      return;\n    var steps = slide.$$('.incremental > *').length + 1,\n        slideSize = 100 / (this.slides.length - 1),\n        stepSize = slideSize / steps;\n    this.progressBar.style.width = ((aIdx - 1) * slideSize + aStep * stepSize) + '%';\n  }\n  \n  Dz.postMsg = function(aWin, aMsg) { // [arg0, [arg1...]]\n    aMsg = [aMsg];\n    for (var i = 2; i < arguments.length; i++)\n      aMsg.push(encodeURIComponent(arguments[i]));\n    aWin.postMessage(aMsg.join(\" \"), \"*\");\n  }\n  \n  function init() {\n    Dz.init();\n    window.onkeydown = Dz.onkeydown.bind(Dz);\n    window.onresize = Dz.onresize.bind(Dz);\n    window.onhashchange = Dz.onhashchange.bind(Dz);\n    window.onmessage = Dz.onmessage.bind(Dz);\n  }\n\n  window.onload = init;"
        H.script "// Helpers\n  if (!Function.prototype.bind) {\n    Function.prototype.bind = function (oThis) {\n\n      // closest thing possible to the ECMAScript 5 internal IsCallable\n      // function \n      if (typeof this !== \"function\")\n      throw new TypeError(\n        \"Function.prototype.bind - what is trying to be fBound is not callable\"\n      );\n\n      var aArgs = Array.prototype.slice.call(arguments, 1),\n          fToBind = this,\n          fNOP = function () {},\n          fBound = function () {\n            return fToBind.apply( this instanceof fNOP ? this : oThis || window,\n                   aArgs.concat(Array.prototype.slice.call(arguments)));\n          };\n\n      fNOP.prototype = this.prototype;\n      fBound.prototype = new fNOP();\n\n      return fBound;\n    };\n  }\n\n  var $ = (HTMLElement.prototype.$ = function(aQuery) {\n    return this.querySelector(aQuery);\n  }).bind(document);\n\n  var $$ = (HTMLElement.prototype.$$ = function(aQuery) {\n    return this.querySelectorAll(aQuery);\n  }).bind(document);\n\n  $$.forEach = function(nodeList, fun) {\n    Array.prototype.forEach.call(nodeList, fun);\n  }"
        --  vim: set fdm=marker: }}} 

