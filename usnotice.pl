use strict;

# Credit: https://gist.github.com/Apsu/5877402

my $Version     = "0.01";
my $SCRIPT      = "notices";
my $AUTHOR      = "MrIron";
my $LICENSE     = "GPL3";
my $DESCRIPTION = "Undernet server notices";

my $SourceServerBuffer;

weechat::register( $SCRIPT, $AUTHOR, $Version, $LICENSE, $DESCRIPTION, "", "");
weechat::hook_modifier("irc_in_notice", "event_serverevent","");

sub event_serverevent {
  my ($data, $signal, $server, $arg) = @_;
  my $message = weechat::info_get_hashtable( "irc_message_parse", { "message" => $arg });

  my $nickname = $$message{nick};
  my $msg = $$message{arguments};
  my $hostmask = $$message{host};
  my $command = $$message{command};

  $SourceServerBuffer = weechat::info_get("irc_buffer",$server);

  # If it is not a NOTICE, we don't want to have anything to do with it.
  if ($command !~ /^NOTICE/) {
    return $arg
  }

  # Server notices have no \@ in them
  if ($hostmask =~ /.*\@.*/) {
        return $arg
  }

  # For a server notice, the source server is stored in $nick.
  # It can happen that a server notice from a different server is sent
  # to us. This notice must not be reformatted.
  if ($nickname ne $hostmask) {
    return $arg
  }

  # Remove the NOTICE part from the message
  # NOTE: this is probably unnecessary.
  $msg =~ s/^.*:\*\*\* //;

  # Set the source server


#Do my parsing thing
  if ( $msg =~ /HACK\(4\): (channels|chanfix)\.undernet\.org MODE ([^\s]+) (.*) \[(\d+)\]/ )
    {
        my $buffer = &findbuffer("CHAN");
	my $timestamp = scalar localtime $4;
        weechat::print_date_tags($buffer,0,"notify_none","[".$server."] HACK(4): $1.undernet.org MODE ". weechat::color("green") . $2 . weechat::color("default") ." $3 [$timestamp]");
        return ""
    }
 elsif ( $msg =~ /G-line active for (.*)/ )
    {
        my $buffer = &findbuffer("GLINE");
        weechat::print_date_tags($buffer,0,"notify_message","[".$server."] G-line active for $1");
        return ""
    }
 elsif ( $msg =~ /uworld\.eu\.undernet\.org adding deactivated global GLINE for (.*), expiring at (\d+):(.*)/ )
    {
        my $buffer = &findbuffer("GLINE");
	my $timestamp = scalar localtime $2;
        weechat::print_date_tags($buffer,0,"notify_message","[".$server."] uworld\.eu\.undernet\.org adding deactivated global GLINE for $1, expiring at $timestamp: $3");
        return ""
    }
  else
    {
	return $arg
    }
}

sub findbuffer {
        my $buffer = weechat::buffer_search("", $_[0]);
        if (!$buffer) {
                $buffer = weechat::buffer_new($_[0],"notices_input","","","");
        }

        return $buffer
}

sub notices_input {
        my($data,$buffer,$input_data) = @_;
        weechat::print("","Got " . $input_data);
        weechat::command($SourceServerBuffer,"/$input_data");
}
