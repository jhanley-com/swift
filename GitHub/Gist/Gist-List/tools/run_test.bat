swift build
@if errorlevel 1 goto err_out

.build\x86_64-unknown-windows-msvc\debug\gist-list --test

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
