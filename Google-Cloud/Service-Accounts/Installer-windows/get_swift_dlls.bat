copy C:\Library\Developer\Toolchains\unknown-Asserts-development.xctoolchain\usr\bin\BlocksRuntime.dll DLLs
@if errorlevel 1 goto err_out

copy C:\Library\Developer\Toolchains\unknown-Asserts-development.xctoolchain\usr\bin\dispatch.dll DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\runtime-development\usr\bin\Foundation.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\runtime-development\usr\bin\FoundationNetworking.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\runtime-development\usr\bin\swiftCore.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\runtime-development\usr\bin\swiftCRT.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\runtime-development\usr\bin\swiftDispatch.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\runtime-development\usr\bin\swiftSwiftOnoneSupport.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\runtime-development\usr\bin\swiftWinSDK.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\icu-69.1\usr\bin\icudt69.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\icu-69.1\usr\bin\icuin69.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\swift\icu-69.1\usr\bin\icuuc69.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\OpenSSL-Win64\libcrypto-3-x64.dll" DLLs
@if errorlevel 1 goto err_out

copy "C:\Program Files\OpenSSL-Win64\libssl-3-x64.dll" DLLs
@if errorlevel 1 goto err_out

@echo *
@echo ***************************************************************
@echo Copy OK         Copy OK         Copy OK         Copy OK
@echo ***************************************************************
@echo *
@echo *

goto end

:err_out
@echo *
@echo *
@echo ***************************************************************
@echo Copy Failed     Copy Failed     Copy Failed     Copy Failed
@echo ***************************************************************
@echo *
@echo *

:end
