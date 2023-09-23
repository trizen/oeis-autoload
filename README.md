# oeis-autoload

**OEIS autoload** is a [Sidef](https://github.com/trizen) command-line tool and a library that implements support for using [OEIS](https://oeis.org) sequences as functions.

Usage example:

```console
$ sidef oeis.sf 'A060881(n)' 0 9    # display first 10 terms of A060881
```

Several other usage examples:

```console
$ sidef oeis.sf 'A033676(n)^2 + A033677(n)^2'              # first 10 terms
$ sidef oeis.sf 'A033676(n)^2 + A033677(n)^2' 5            # 5-th term
$ sidef oeis.sf 'A033676(n)^2 + A033677(n)^2' 5 20         # terms 5..20
```

The ID of a [OEIS](https://oeis.org) sequence can be called like any other function:

```console
$ sidef oeis.sf 'sum(1..n, {|k| A000330(k) })'
$ sidef oeis.sf 'sum(0..n, {|k| A048994(n, k) * A048993(n+k, n) })'
```

The `OEIS.sm` library can also be used inside Sidef scripts, by placing it in the same directory with the script:

```ruby
include OEIS
say map(1..10, {|k| A000330(k) })
```
