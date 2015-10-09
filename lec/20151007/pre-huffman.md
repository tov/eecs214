# Prefix codes

## What is a code?

An *alphabet* is a set of symbols.

  - { 0, 1 }
  - { a, b, ..., z }
  - { †, ‡, §, ¶ }
  - { A, a, B, b, ..., Z, z, 0, 1, ... 9, ' ' }
  - { '\000', '\001', ..., '\255' } ('\065' == 'A')

Given an alphabet S, then S∗ means the set of all sequences of symbols
in S.

  - if S = { 0, 1 }
    then S∗ = { ε, 0, 1, 00, 01, 10, 11, 000, … }

  - if S = { a, b, ..., z }
    then S∗ = { ε, a, b, ..., z, aa, ab, ..., az, ba, bb, ..., bz, ... }

Given two alphabets S and T, a code is an injection from S∗ to T∗.

  - ASCII (American Standard CODE for Information Interchange):
      - S is 128 writing symbols (letters, digits, spaces, punctuation, …)
      - T is { 0, 1 }

  - let f: { †, ‡, §, ¶ }∗ → { a, b }∗ where

        f(ε)     = ε
        f(† ∘ w) = aa ∘ f(w)
        f(‡ ∘ w) = bb ∘ f(w)
        f(§ ∘ w) = ab ∘ f(w)
        f(¶ ∘ w) = ba ∘ f(w)

f is *block code*: encodes each symbol with a discrete code word of the
same length. Code words for f:

        f(†) = aa
        f(‡) = bb
        f(§) = ab
        f(¶) = ba

ASCII is also a block code.

(Note: an *arithmetic code* overlaps code words, kinda.)

## Entropy coding

Use shorter code words for more common input symbols, longer for rarer.

We need a *model* of the input.

  - E.g., letter frequencies for English text: e, t, a, o, i, n, s, r, h, d

      - e 0   (THIS IS NO GOOD!)
      - t 1
      - a 00
      - o 01
      - i 10
      - n 11
      - s 000
      - r 001
      - h 010
      - d 011
      - and so on ...

original message: "detain"
coded message: 01101001011

one possible decoding: eneihn

So, not injective.

Use separators?:
  - output language: { 0, 1, - }
  - 011-0-10-01-011

## Prefix code

(a/k/a prefix-free code)

Definition: no code word is a prefix of any other.

Code with prefix property:
  - e 00
  - t 01
  - a 100
  - o 101
  - i 1100
  - n 1101
  - s 11100
  - r 11101
  - h 11110
  - d 11111

original message: "detain"
coded message: 11111000110011001101

## Prefix code tree


