  package Shari::Conf;
# ********************
# ABSTRACT: Abstract Configuration Source derived from Gantry::Conf
use strict; use warnings; use utf8;
$Shari::Conf::VERSION='0.03';

; use Carp ()
; use Capture::Tiny ()
; use Config::General ()
; use Hash::Merge ()
; use File::Basename ()
; use File::Spec ()

# Dispatch table
; my %dispatch;
; my $C = __PACKAGE__

# Ene Aktion die für die erste geladene Konfiguration genutzt werden kann.
; sub _default_post_load
    { my ($self,$instance) = @_
    ; my %config = %{$self->{'__config__'}}
    ; $self->{'__config__'} = {}
    ; my $instance_ref = $config{'instance'}->{$instance}

    ; my @configure_via =
         $self->array_option($instance_ref->{'ConfigureVia'})

    # Handle all ConfigureVia statements
    ; foreach my $via ( @configure_via )
        { my ( $provider, @params ) = split /\s+/, $via
        ; $self->configure_via($provider,@params)
        }

    ; $self->merge_config($config{'global'})
    }

; sub new
    { my $class = shift
    ; my $self = {
        __config__ => {},
        __apply__ => \&_default_post_load
    }

    ; return bless( $self, $class )
    }

; sub register_config_provider
    { my ($self,$name,$action) = @_

    ; $dispatch{$name} = $action
    }

; sub set_apply_action
    { my ($self,$action) = @_
    ; $self->{'__apply__'} = $action
    }

; sub run_apply_action
    { my ($self,@args) = @_
    ; if(defined $self->{'__apply__'})
        { $self->{'__apply__'}->($self,@args)
        ; $self->{'__apply__'} = undef
        }
    }

; sub set_config_dir
    { my ($self,$dir) = @_
    ; $self->{'__config_dir__'} = $dir
    }

; sub get_config_dir
    { my ($self) = @_
    ; $self->{'__config_dir__'}
    }

; sub get_config_file
    { my ($self,$file) = @_
    ; File::Spec->catfile($self->get_config_dir,$file)
    }

; sub slurp_config_file
    { my ($self,$file) = @_;
    ; open( my $fh, '<', $self->get_config_file($file) )
          or Carp::croak("Can not open file '$file': $!");
    ; local $/;
    ; <$fh>
    }

; sub array_option
    { my ($self,$ref,@default) = @_
    ; my @config_statements

    ; if ( ref( $ref ) =~ /ARRAY/ )
        { @config_statements = @{ $ref }
        }
      elsif ( not defined $ref )
        { push @config_statements, @default
        }
      else
        { push @config_statements, $ref
        }
    ; return @config_statements
    }

; $C->register_config_provider(
    'Config::General' => sub
        { my ($self,$filename) = @_
        ; my $config = File::Spec->catfile(
             $self->get_config_dir, $filename)
        ; my $cfg = $self->config_general(-ConfigFile =>  $config)
        ; $self->merge_config({$cfg->getall})
        })

; sub configure_via
    { my ($self,$provider,@args) = @_
    ; my $action = $dispatch{ $provider }

    ; Carp::croak "ERROR: No such ConfigureVia provider: $provider\n"
        unless $action;

    ; $action->($self,@args);
    }

; sub config_general
    { my $self = shift
    ; Config::General->new
        (
             -UseApacheInclude   =>  1,
             -IncludeGlob        =>  1,
             -IncludeDirectories =>  1,
             -IncludeRelative    =>  1,
             -UTF8               =>  1,
             @_
        )
    }

; sub merge_config
    { my ($self,$conf) = @_
    ; my $merge = Hash::Merge->new('LEFT_PRECEDENT')
    ; $merge->set_clone_behavior(0)
    ; Capture::Tiny::capture {
      ; $self->{'__config__'} = $merge->merge($self->{'__config__'},$conf)
      }
    }

; sub load_main_config
    { my ($self,$params,@args) = @_
    ; $self = $self->new unless ref $self
    ; $self->{'__config__'} = {}

    ; my $provider = $params->{'provider'} || 'Config::General'

    ; Carp::croak "ERROR: No instance given to load_main_config()"
        unless ( $params->{'instance'} )

    ; my $configfile = $params->{'config_file'}
    ; Carp::croak "ERROR: No config file given to load_main_config()"
        unless $configfile

    ; unless(ref $configfile)
        { my $dir = File::Basename::dirname($configfile)
        ; $configfile = File::Basename::basename($configfile)
        ; $self->set_config_dir($dir)
        }
    ; $self->load_configuration($provider, $configfile, @args)
    ; $self->run_apply_action($params->{'instance'})

    # Return our configuration
    ; return( $self->{__config__} );
    }

; sub load_configuration
    { my ($self,$provider,@args) = @_

    ; $self->configure_via($provider,@args)
    }

; 1

__END__

=head1 NAME

Shari::Conf - Extensible Configuration System

=head1 SYNOPSIS

  use Shari::Conf;

  Shari::Conf->register_config_provider(
      'YAML' => sub {
         my ($self,$file) = @_;
         $self->merge_config(YAML::Load($file));
      });

  my $conf = Shari::Conf->new;
  my $config = $conf->load_main_config({
      instance => 'foo',
      config_file => 'root.conf'
  });


  # root.conf
  <global>
     name foo

     option 1
     color white
  </global>

  <instance foo>
      ConfigureVia YAML data.yml
  </instance>

=head1 DESCRIPTION

This module is an modified fork of Gantry::Conf. The behaviour is
similar, but not all features are included from original. It
uses only one config loader - Config::General. But it is possible
to add more.

=head2 CLASS METHODS

=over 4

=item new

Nothing special here, this method creates an object.

=item register_config_provider($name, $action)

This method adds or overwrites an entry in the dispatch table. The
second parameter is called like a usual method, with $self as
first argument. The other arguments are arbitrary.

=back

=head2 OPTIONAL CLASS METHOD

=over 4

=item load_main_config( $options_hash , @optional_args )

This method is loads the confiuration and returns the loaded
configuration data as a hash reference. The first argument
is a hashref, which defines behavior of the method.

The possible keys in this hashref are:

=over 4

=item provider => 'provider_name'

The value is a name which was registered with register_config_provider.
The usual default is 'Config::General'.

=item instance => 'foo'

This is the unique name of the "instance" of this application.  This is
typically the only option given to retrieve() and is what is used to
bootstrap the rest of the configuration process.  This "instance" name
must match an entry in the configuration file.

=item config_file => '/path/to/file.conf'

=back

All following parameters are used as argument list for the
L<load_configuration> method.

=back

=head2 OBJECT METHODS



=head1 SEE ALSO

Gantry::Conf(3), Gantry::Conf::Tutorial(3), Ganty::Conf::FAQ(3)

=head1 AUTHOR

Gantry::Conf written by Frank Wiles <frank@revsys.com>

Shari::Conf development running by Sebastian Knapp <rock@ccls-online.de>

=head1 COPYRIGHT and LICENSE

Copyright (c) 2006, Frank Wiles.

Copyright (c) 2011-2012 Sebastian Knapp

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

