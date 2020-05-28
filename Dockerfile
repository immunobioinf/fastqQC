# Dockerfile for rnaseqreadqc

# Generate minimal linux system containing the needed packages>
FROM debian:stretch
RUN apt-get update -y && apt-get install apt-file -y && apt-file update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base make cmake pandoc git vim wget default-jre
RUN Rscript -e 'install.packages(c("rmarkdown", "pheatmap"), repos="https://cran.uni-muenster.de")'

# compile and install FastqPuri
RUN cd /home && git clone https://github.com/jengelmann/FastqPuri
RUN cd /home/FastqPuri && cmake -H. -Bbuild/ -DRSCRIPT=/usr/bin/Rscript
RUN cd /home/FastqPuri/build && make && make install

# install FastQC
RUN cd /home && wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip && unzip fastqc_v0.11.9.zip
RUN chmod 755 /home/FastQC/fastqc && ln -s /home/FastQC/fastqc /usr/local/bin/fastqc

# Start command
WORKDIR /tmp
CMD ["bash"]

# Suggestions for a docker usage from the working directory:
# Interactive: ~> docker run -u $(id -u):$(id -g) -v $PWD:/tmp -v /path/to/fastqs/:/home/fastqs -v /path/to/reports:/home/reports -it immunobioinf/rnaseqreadqc:v1
# As pipeline: ~> docker run -u $(id -u):$(id -g) -v $PWD:/tmp -v /path/to/fastqs/:/home/fastqs -v /path/to/reports:/home/reports immunobioinf/rnaseqreadqc:v1 ./QCPipeline.sh
