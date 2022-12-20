"C:\Program Files (x86)\Inno Setup 6\iscc" /Qp setup.iss
@if errorlevel 1 goto err_out

@echo *
@echo ***************************************************************
@echo Build OK         Build OK         Build OK         Build OK
@echo ***************************************************************
@echo *
@echo *

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
