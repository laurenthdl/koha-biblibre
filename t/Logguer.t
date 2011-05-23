package LogTest;

use C4::Logguer;
$log_opac = C4::Logguer->new('opac');

sub test{

    $log_opac->normal('test normal log');

    $log_opac->critical("critical!");
    $log_opac->error("error");
    $log_opac->warning("warning");
    $log_opac->normal("normal");
    $log_opac->info("info");
    $log_opac->debug("debug");
    my $struct = {
        a => "aaaaa",
        b => "bbbbb",
        c => "ccccc"
    };
    $log_opac->info($struct, 1);
    $log_opac->debug($struct, "warn");

}

test;
