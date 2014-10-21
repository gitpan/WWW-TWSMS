package WWW::TWSMS;

use 5.006;
use strict;
use warnings;
use HTTP::Request::Common qw(GET POST);
use HTTP::Cookies;
use LWP::UserAgent;


require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use WWW::TWSMS ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.



sub new {
	
	my $class = shift;
	my $self  = {NOTHING            => 'nothing'};
	my %args  = @_;
	
	bless($self, $class);
	$self->reset();

	$self->{m_Username}     = $args{Username} if (defined $args{Username});
	$self->{m_Password}     = $args{Password} if (defined $args{Password});
	$self->{m_SmsType}	= $args{SmsType} if (defined $args{SmsType});
	$self->{m_SmsPopup}	= $args{SmsPopup} if (defined $args{SmsPopup});
	$self->{m_SmsMo}	= $args{SmsMo} if (defined $args{SmsMo});
	$self->{m_SmsEncoding}	= $args{SmsEncoding} if (defined $args{SmsEncoding});
	$self->{m_SmsVldtime}	= $args{SmsVldtime} if (defined $args{SmsVldtime});
	$self->{m_SmsDlvtime}	= $args{Dlvtime} if (defined $args{Dlvtime});

	return $self;
}


sub reset {

	# pop value
	my $self = shift();

	# check to make sure that this function is being called on an object
	die "You must instantiate an object to use this function" if !(ref($self));

	#-----------------------------------------------------------------
	# Define default package vars
	#-----------------------------------------------------------------
	
	$self->{m_SoftwareWebsite}		= "www.twsms.com";
	$self->{m_SoftwareTitle}		= "Perl TWSMS API";

	
	$self->{m_ErrorCode}			= 0;
	$self->{m_ErrorDescription}		= undef;
	$self->{m_ErrorResolution}		= undef;
    
	$self->{m_StatusCode}			= undef;
	$self->{m_StatusDescription}		= undef;

	
	$self->{m_SmsType}			= 'now';	# now => �ߧY�ǰe , dlv => �w���o�e
	$self->{m_SmsPopup}			= '';		# 1 => ��²�T����ܦb����e���A�����|�s����
	$self->{m_SmsMo}			= '';		# Y => ���V²�T
	$self->{m_SmsEncoding}			= 'big5';	# big5  => ���^�媺���e�A���׬�70�Ӧr��
								# ascii => �­^�媺���e�A���׬�160�Ӧr��
	$self->{m_SmsReceiver}			= undef;	# ����²�T��������X
	$self->{m_SmsVldtime}			= undef;	# ���Ĵ����A�H�����
	$self->{m_SmsDlvtime}			= undef;	# �w���ɶ��A�榡��YYYYMMDDHHII�A�p200405121830
								# ��m_SmsType TAG��dlv�~����

	$self->{m_Secure}			= 0;
	$self->{m_ConnectionTimeout}		= 30;
	$self->{m_RemoteHost}			= 'api.twsms.com';
	$self->{m_RemotePort}			= 80;
	
	$self->{m_Username}			= undef;
	$self->{m_Password}			= undef;


	
}

sub msgReceiver {

	my $self = shift;
	if (@_ == 1) {
		$self->{m_SmsReceiver} = shift() if ($_[0] =~ m/^\d{10}$/);	
	}

	return $self->{m_SmsReceiver} if defined($self->{m_SmsReceiver}) || return undef;
}

sub msgData {

	my $self = shift;
	
	# check to make sure that this function is being called on an object
	die "You must instantiate an object to use this function" if !(ref($self));

	if (@_ == 1) { $self->{m_SmsMsgData} = shift(); }

	return $self->{m_SmsMsgData} if defined($self->{m_SmsMsgData}) || return undef;	
}

sub msgSend {
	
	my $self = shift;

        my $ua = LWP::UserAgent->new;
           $ua->agent('Mozilla/5.0');

        my $req = POST "http://$self->{m_RemoteHost}/send.php",
                [
			'username' => $self->{m_Username},
			'password' => $self->{m_Password},
			'type'	   => $self->{m_SmsType},
			'encoding' => $self->{m_SmsEncoding},
			'mobile'   => $self->{m_SmsReceiver},
			'message'  => $self->{m_SmsMsgData},
			'popup'	   => $self->{m_SmsPopup},
			'mo'	   => $self->{m_SmsMo},
			'vldtime'  => $self->{m_SmsVldtime},
			'dlvtime'  => $self->{m_SmsDlvtime}
                ];

	my $file = $ua->request($req)->as_string;
	my $CheckRes = $1 if ($file =~ m/msgid=(.*)/);
	if ($CheckRes <= 0){
		$self->errorCode($CheckRes);
		$self->statusDescription('�ǰe����');
	} else {
		$self->statusCode($CheckRes);
		$self->statusDescription('�ǰe����');
	}
	
}

sub statusCode {
	# pop value
    my $self = shift();
	
	# check to make sure that this function is being called on an object
    die "You must instantiate an object to use this function" if !(ref($self));

    if (@_ == 1) { $self->{m_StatusCode} = shift(); }

    return $self->{m_StatusCode} if defined($self->{m_StatusCode}) || return undef;
}

sub statusDescription {
	# pop value
    my $self = shift();
	
	# check to make sure that this function is being called on an object
    die "You must instantiate an object to use this function" if !(ref($self));

    if (@_ == 1) { $self->{m_StatusDescription} = shift(); }

    return $self->{m_StatusDescription} if defined($self->{m_StatusDescription}) || return undef;
}

sub errorCode {
	# pop value
	my $self = shift();
	my %ERR_DESCRIPTION = ( '-1' => '�o�e����',
				'-2' => '�b���αK�X���~',
				'-3' => 'popup TAG �]�w���~',
				'-4' => 'mo TAG �]�w���~',
				'-5' => 'encoding TAG �]�w���~',
				'-6' => 'mobile TAG �]�w���~',
				'-7' => 'message TAG �]�w���~',
				'-8' => 'vldtime TAG �]�w���~',
				'-9' => 'dlvtime TAG �]�w���~',
				'-10' => '²�T�q�Ƥ���',
				'-11' => '�b������',
				'-12' => 'type TAG �]�w���~',
				'-13' => '��ϥ�wap push�\���,���i�ĥιw���覡�o�e',
				'-14' => '�ӷ�IP�S���ϥ��v��',
				'-99' => '�t�ο��~�]�p�X�{�����~,�гq���ȪA���ߡ^'
			);	
	# check to make sure that this function is being called on an object
    die "You must instantiate an object to use this function" if !(ref($self));



    if (@_ == 1) { 
    	$self->{m_ErrorCode} = shift(); 
	$ERR_DESCRIPTION{$self->{m_ErrorCode}} ? $self->errorDescription($ERR_DESCRIPTION{$self->{m_ErrorCode}}) : $self->errorDescription($self->{m_ErrorCode});
    }

    return $self->{m_ErrorCode} if defined($self->{m_ErrorCode}) || return undef;
}

sub errorDescription {
	# pop value
    my $self = shift();

	# check to make sure that this function is being called on an object
    die "You must instantiate an object to use this function" if !(ref($self));

    if (@_ == 1) { $self->{m_ErrorDescription} = shift(); }

    return $self->{m_ErrorDescription} if defined($self->{m_ErrorDescription}) || return undef;
}

sub success {
	# pop value
    my $self = shift();
	
	# check to make sure that this function is being called on an object
    die "You must instantiate an object to use this function" if !(ref($self));

    # if the error_code is between 0 and 10 then its an okay response.
    if ($self->errorCode > 0) {
        return 1;
    }
    
    return 0;
}



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

WWW::TWSMS - Perl extension for send sms by TWSMS. (http://www.twsms.com)

=head1 SYNOPSIS

  use WWW::TWSMS;
  $sms = WWW::TWSMS->new(Username => "username", 
                         Password => "password", 
                         SmsType => 'now', 
                         SmsEncoding => 'big5'
                        );
  $sms->msgReceiver("phone_number");
  $sms->msgData("hello world");
  $sms->msgSend();
  $sms->success() or die $sms->errorDescription."\n" ;

=head1 DESCRIPTION

This's a Perl interface for send sms by TWSMS. (http://www.twsms.com)

=head1 WWW::TWSMS->new

$sms = new WWW::TWSM->new(Username => 'uname', Password => 'password', ...)

The following arguments may be passed to new as a hash.

=over 4

=item Username

Your Username in the website of TWSMS

=item Password

Your Password in the website of TWSMS

=item SmsType

default 'now', [dlv]

'now' mean send SMS now. 
'dlv' mean send SMS at a reserved time.

=item SmsPopup

default '',[1]

if SmsPopup = 1 

mean the SMS context will show on the screen of Receiver's mobile phone,

but will not  save into Receiver's mobile phone.

=item SmsMo

default '', micro-seconds before retry

=item SmsEncoding

default 'big5' , ['ascii','unicode','push','unpush']

big5:    the SMS context in Chinese or Engilsh, the max of SMS context length is 70 character.
ascii:   the SMS context in Engilsh, the max of SMS context length is 160 character.
unicode: the SMS context in Unicode.

=item SmsVldtime

SmsVldtime mean the available time of SMS.

Its unit in sec. Example: 86400 (mean 24 hours)

=item SmsDlvtime

SmsDlvtime mean send SMS at a reserved time.

Its format is YYYYMMDDHHII.

Example: 200607291730  (mean 2006/07/29 17:30)


=head2 EXPORT

None by default.



=head1 SEE ALSO

The API document of TWSMS

http://www.twsms.com/dl/api_doc.zip

=head1 WEBSITE

You can find information about TWSMS at :

   http://www.twsms.com/

=head1 AUTHOR

Tsung-Han Yeh, E<lt>snowfly@yuntech.edu.twE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Tsung-Han Yeh

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
