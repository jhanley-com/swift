@set IMAGE_NAME=swift-request
@set PROJECT_ID=REPLACE_ME

call gcloud builds submit ^
--tag gcr.io/%PROJECT_ID%/%IMAGE_NAME%
@if errorlevel 1 goto err_out

goto end

:err_out
@echo ***************************************************************
@echo Build Failed     Build Failed     Build Failed     Build Failed
@echo ***************************************************************

:end
