@Echo Off
Echo --------------------------------------------------------------------------
Echo                      Auto install cygwin
Echo --------------------------------------------------------------------------

SetLocal
  For /F %%D In ("%CD%") Do Set DRIVE=%%~dD
  
  Set DEFAULT_SITE=http://mirror.csclub.uwaterloo.ca/cygwin/

  Set CUR_DIR=%CD:\=/%

  Set DEFAULT_ROOT_DIR=%DRIVE%/.cygwin
  Set DEFAULT_LOCAL_DIR=%DEFAULT_ROOT_DIR%/.tmp

  Set SITE=-s "%DEFAULT_SITE%"
  Set LOCAL_DIR=-l "%DEFAULT_LOCAL_DIR%"
  Set ROOT_DIR=-R "%DEFAULT_ROOT_DIR%"

  Set REMOTE_SETUP_FILE=http://www.cygwin.com/setup.exe
  Set LOCAL_SETUP_FILE=%DEFAULT_LOCAL_DIR%/setup.exe

  Set WGET=%CUR_DIR%/wget.exe
  Set BASH=%DEFAULT_ROOT_DIR%/bin/bash.exe

Rem -------------------------------------
Rem Download cygwin setup.exe
Rem -------------------------------------

  Echo [INFO] Downloading cygwin setup.exe
  If Exist %DEFAULT_LOCAL_DIR% (
    Rem %DEFAULT_LOCAL_DIR% already created.
  ) Else (
    MkDir "%DEFAULT_LOCAL_DIR%"
  )


  If Exist %LOCAL_SETUP_FILE% (
     Echo [INFO] Cygwin setup was downloaded
  ) Else (
    %WGET% "%REMOTE_SETUP_FILE%" -O "%LOCAL_SETUP_FILE%"
    If Exist %LOCAL_SETUP_FILE% (
       Echo [INFO] Cygwin setup.exe was downloaded
    ) Else (
      Echo [FATAL]: Cygwin setup.exe was not downloaded
      GoTo end
    )
  )

Rem -------------------------------------
Rem Setup cygwin
Rem -------------------------------------
  
  Echo [INFO] Install cygwin to %DEFAULT_ROOT_DIR%

  Set PACKAGES=-P wget
  Set PACKAGES=%PACKAGES%,bzip2
  Set PACKAGES=%PACKAGES%,subversion
  Set PACKAGES=%PACKAGES%,git
  Set PACKAGES=%PACKAGES%,chere
  Set PACKAGES=%PACKAGES%,vim
  Set PACKAGES=%PACKAGES%,openssh

  Rem Do the actual cygwin install
  Echo [INFO] "%LOCAL_SETUP_FILE%" -q -n -D -L %SITE% %LOCAL_DIR% %ROOT_DIR% %PACKAGES%
  "%LOCAL_SETUP_FILE%" -q -n -D -L %SITE% %LOCAL_DIR% %ROOT_DIR% %PACKAGES%

  Echo [INFO] Cygwin installation is complete

Rem -------------------------------------
Rem Setup environment variables
Rem -------------------------------------

  Echo [INFO] Add environment variables.
  Set LAST_CHAR=%PATH:~-1%
  Set SEMI_COMMA=;
  Set CYGWIN_HOME=%DEFAULT_ROOT_DIR:/=\%
  Set CYGWIN_HOME_BIN_PATH=%CYGWIN_HOME%\bin;
  
  Echo "SetX /M CYGWIN_HOME %CYGWIN_HOME%"
  SetX /M CYGWIN_HOME %CYGWIN_HOME%

  SetLocal EnableDelayedExpansion
    If "%LAST_CHAR%"=="%SEMI_COMMA%" (
      Echo "SetX /M PATH !PATH:%CYGWIN_HOME_BIN_PATH%=!%CYGWIN_HOME_BIN_PATH%"
      SetX /M PATH "!PATH:%CYGWIN_HOME_BIN_PATH%=!%CYGWIN_HOME_BIN_PATH%"
    ) Else (
      Echo "SetX /M PATH !PATH:%CYGWIN_HOME_BIN_PATH%=!;%CYGWIN_HOME_BIN_PATH%"
      SetX /M PATH "!PATH:%CYGWIN_HOME_BIN_PATH%=!;%CYGWIN_HOME_BIN_PATH%"
    )   
  EndLocal

Rem -------------------------------------
Rem Custom cygwin
Rem -------------------------------------

  Echo [INFO] Cygwin custom configuration

  If Exist %BASH% (
    GoTo custom
  ) Else (
    Echo "Cannot find %BASH%
    GoTo end
  )

:custom
Rem -------------------------------------
Rem Install apt-cyg
Rem -------------------------------------

  Echo [INFO] Installing the apt-cyg stuff as it has to be installed seperatly
  %BASH% --norc --noprofile -c "/usr/bin/svn --force export http://apt-cyg.googlecode.com/svn/trunk/ /bin/"
  %BASH% --norc --noprofile -c "/usr/bin/chmod +x /bin/apt-cyg"

Rem -------------------------------------
  Set START_BASH_HERE='Start bash here...'
Rem Add %START_BASH_HERE% 
Rem -------------------------------------

  Echo [INFO] Add %START_BASH_HERE% to contex menu
  %BASH% --norc --noprofile -c "/usr/bin/chere -if -t mintty -s bash -e %START_BASH_HERE%"

:end

EndLocal

Exit /B 0