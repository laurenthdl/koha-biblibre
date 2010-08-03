package Plack::Middleware::Debug::MemLeak;
  use Devel::Symdump;
  use Devel::Size;
  use YAML qw(Dump);
  use parent qw(Plack::Middleware::Debug::Base);
  no strict;
  sub run {
      my($self, $env, $panel) = @_;

      my @packs = qw(main);
      my $obj = Devel::Symdump->rnew(@packs);
      my %size;
      for my $element (grep{ $_!~/::[A-Z_]+$/} $obj->scalars, $obj->arrays, $obj->hashes){
          $size{$element}=Devel::Size::total_size(${"$element"});
      }

      return sub {
          my $res = shift;

          my $newobj = Devel::Symdump->rnew(@packs);       
             
          for my $element ( grep {$_!~/::[A-Z_]+$/} $newobj->scalars, $newobj->arrays, $newobj->hashes){
                my $current_size=Devel::Size::total_size(${"$element"});
                
                if ($current_size>16 && ((exists ($size{$element}) && $size{$element}<$current_size) || (!exists ($size{$element})))){
                    $size{$element}=$current_size;
                   # $size{$element}=$element,Dump(${"$element"});
                }
                else {
                    delete $size{$element};
                }
          }
          $panel->nav_title("Memory Usage");
          $panel->nav_subtitle("Memory Usage");
          $panel->content(
              $self->render_list_pairs(
                  [ %size
                  ],
              ),
          );
      };
  }
1;
