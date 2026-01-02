[![Actions Status](https://github.com/FCO/SupplyTimeWindow/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/SupplyTimeWindow/actions)

NAME
====

SupplyTimeWindow - time-windowed arrays from a Supply

SYNOPSIS
========

```raku
use SupplyTimeWindow;

my $s = Supplier.new;
my $t = $s.Supply.time-window: 1;

start react whenever $t { .say }

for ^10 -> $i { $s.emit: $i; sleep .5.rand }
```

Window transforms:

```raku
# emit the count of items in the last second
$s.Supply.time-window(1, :transform(*.elems)).tap(*.say);

# emit the sum of the last 2 seconds
$s.Supply.time-window(2, :transform(*.sum)).tap(*.say);
```

DESCRIPTION
===========

SupplyTimeWindow augments all Raku `Supply` objects with a `time-window` method. Given a window size in seconds, it emits on every upstream event an `Array` containing all values whose event timestamp lies within the interval `[now - $seconds, now]`. Windows are computed from arrival time using `now` (an `Instant`), and are sliding rather than tumbling.

METHODS
=======

`method time-window($seconds --> Supply)`
-----------------------------------------

  * Parameters: `$seconds` (Numeric > 0), window length in seconds.

  * Returns: `Supply` that emits `Array` of recent values each time the source emits.

  * Behavior: The first emission is `[value]`. Subsequent emissions contain the current value plus those still within the last `$seconds`.

`method time-window($seconds, :&transform! --> Supply)`
-------------------------------------------------------

  * Parameters: `$seconds` and mandatory `:transform` callable (`Callable`).

  * Returns: `Supply` that emits the result of applying `transform` to each window array.

  * Usage: Pass any callable; examples include `*.sum`, `*.elems`, or a block.

NOTES
=====

  * Window membership uses `(last_timestamp - $seconds)` as the cutoff.

  * If `$seconds` is `0`, the supply emits single-element arrays (or transform of those).

  * The method does not buffer or delay upstream events; it computes the window on the fly.

  * Works with any `Supply` (e.g., from `Supplier`, IO events, timers).

SEE ALSO
========

`Supply`, `Supplier`, `react`, `whenever`, `produce`, `map`.

