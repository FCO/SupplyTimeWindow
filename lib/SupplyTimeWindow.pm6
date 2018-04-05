use MONKEY-TYPING;
augment class Supply {

    multi method time-window($seconds) {
        self
            .map(-> $i {[{:time(now), :value($i)},]})
            .produce(-> @arr, @last {
                [ |@arr.skip(@arr.first(:k, {.<time> >= @last.head<time> - $seconds}) // @arr.elems), |@last]
            })
            .map(-> $values { @($values)>>.<value> })
        ;
    }

    multi method time-window($seconds, :&transform!) {
        callwith($seconds)
            .map(&transform)
        ;
    }
}
