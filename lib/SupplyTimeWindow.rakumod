=begin pod

=head1 NAME

SupplyTimeWindow - time-windowed arrays from a Supply

=head1 SYNOPSIS

=begin code :lang<raku>

use SupplyTimeWindow;

my $s = Supplier.new;
my $t = $s.Supply.time-window: 1;

start react whenever $t { .say }

for ^10 -> $i { $s.emit: $i; sleep .5.rand }

=end code

Window transforms:

=begin code :lang<raku>

# emit the count of items in the last second
$s.Supply.time-window(1, :transform(*.elems)).tap(*.say);

# emit the sum of the last 2 seconds
$s.Supply.time-window(2, :transform(*.sum)).tap(*.say);

=end code

=head1 DESCRIPTION

SupplyTimeWindow augments all Raku C<Supply> objects with a C<time-window> method.
Given a window size in seconds, it emits on every upstream event an C<Array>
containing all values whose event timestamp lies within the interval
C<[now - $seconds, now]>. Windows are computed from arrival time using C<now>
(an C<Instant>), and are sliding rather than tumbling.

=head1 METHODS

=head2 C<<method time-window($seconds --> Supply)>>

=item Parameters: C<$seconds> (Numeric > 0), window length in seconds.
=item Returns: C<Supply> that emits C<Array> of recent values each time the source emits.
=item Behavior: The first emission is C<[value]>. Subsequent emissions contain the current value plus those still within the last C<$seconds>.

=head2 C<<method time-window($seconds, :&transform! --> Supply)>>

=item Parameters: C<$seconds> and mandatory C<:transform> callable (C<Callable>).
=item Returns: C<Supply> that emits the result of applying C<transform> to each window array.
=item Usage: Pass any callable; examples include C<*.sum>, C<*.elems>, or a block.

=head1 NOTES

=item Window membership uses C<(last_timestamp - $seconds)> as the cutoff.
=item If C<$seconds> is C<0>, the supply emits single-element arrays (or transform of those).
=item The method does not buffer or delay upstream events; it computes the window on the fly.
=item Works with any C<Supply> (e.g., from C<Supplier>, IO events, timers).

=head1 SEE ALSO

C<Supply>, C<Supplier>, C<react>, C<whenever>, C<produce>, C<map>.

=end pod

use MONKEY-TYPING;
augment class Supply {

    multi method time-window($seconds --> Supply) {
        self
            .map(-> $i {[{:time(now), :value($i)},]})
            .produce(-> @arr, @last {
                [ |@arr.skip(@arr.first(:k, {.<time> >= @last.head<time> - $seconds}) // *), |@last ]
            })
            .map(-> $values { @($values)>>.<value> })
        ;
    }

    multi method time-window($seconds, :&transform! --> Supply) {
        callwith($seconds)
            .map(&transform)
        ;
    }
}
