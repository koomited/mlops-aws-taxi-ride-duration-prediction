export MODEL_BUCKET_PROD="koomi-stg-mlflow-models-mlops-zoomcamp"
export PREDICTION_STREAM_NAME="stg-ride-predictions-mlops-zoomcamp"
export LAMBDA_FUNCTION="ride-duration-prediction" #stg-prediction-lambda-mlops-zoomcamp


export MODEL_BUCKET_DEV="koomi-mlflow-artifacts-remote"

export RUN_ID=$(aws s3api list-objects-v2 \
    --bucket ${MODEL_BUCKET_DEV} \
    --query "sort_by(Contents, &LastModified)[-1].Key" \
    --output text | cut -f3 -d/)

aws s3 sync s3://${MODEL_BUCKET_DEV} s3://${MODEL_BUCKET_PROD}

variables="{PREDICTION_STREAM_NAME=${PREDICTION_STREAM_NAME}, MODEL_BUCKET=${MODEL_BUCKET_PROD}, RUN_ID=${RUN_ID}}"

aws lambda update-function-configuration --function-name ${LAMBDA_FUNCTION} --environment "Variables=${variables}"