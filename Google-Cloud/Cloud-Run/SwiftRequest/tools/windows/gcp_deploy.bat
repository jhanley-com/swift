@set IMAGE_NAME=swift-request
@set PROJECT_ID=REPLACE_ME
@set REGION=us-central1

gcloud run deploy swift-request ^
--platform managed ^
--region %REGION% ^
--image gcr.io/%PROJECT_ID%/%IMAGE_NAME% ^
--memory 128Mi ^
--allow-unauthenticated
@if errorlevel 1 goto err_out

goto end

:err_out
@echo ***************************************************************
@echo Deploy Failed   Deploy Failed    Deploy Failed    Deploy Failed
@echo ***************************************************************

:end
