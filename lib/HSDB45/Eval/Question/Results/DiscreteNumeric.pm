package HSDB45::Eval::Question::Results::DiscreteNumeric;

use strict;
use base qw(HSDB45::Eval::Question::Results);

sub is_numeric {
    return 1;
}

sub is_binnable {
    return 1;
}

1;
