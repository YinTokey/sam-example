FROM solace/solace-agent-mesh:latest
WORKDIR /app

# Install Python dependencies
COPY ./requirements.txt /app/requirements.txt
RUN python3 -m pip install --no-cache-dir -r /app/requirements.txt

# Copy project files
COPY . /app

CMD ["run", "--system-env"]

# To run one specific component, use:
# CMD ["run", "--system-env", "configs/agents/main_orchestrator.yaml"]
