swift build
@if errorlevel 1 goto err_out

:: .build\x86_64-unknown-windows-msvc\debug\auth-device --debug
.build\x86_64-unknown-windows-msvc\debug\auth-device 

goto end

:err_out
@echo *
@echo *
@echo ***************************************************************
@echo Build Failed     Build Failed     Build Failed     Build Failed
@echo ***************************************************************
@echo *
@echo *

:end
