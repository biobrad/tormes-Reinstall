#!/bin/bash
#
# script to perform a clean re-install of the tormes conda environment
# without re-downloadinging the 8 gig kraken database
# Written by Brad Hart - June 2021
#
conda_base=$(conda info --base)
tormesenv=$(conda env list | grep tormes | awk '{print $1}')
tormeshome=$(conda env list | grep tormes | awk '{print $2}')
mytormes=$(echo "${tormeshome}" | sed "s/$/\/bin\/tormes/")
tormesver=$(${mytormes} -v | awk '{print $3}')
#
mkdir ${conda_base}/envs/tormestemp
#
echo -e "\nCopying Tormes Minikraken Database to Temporary location\n"
sleep 1
#
cp -r ${tormeshome}/db/minikraken-DB ${conda_base}/envs/tormestemp
#
## I would like to use the ${tormesver} variable in the http string so in future versions 
## it gets the yml for the version that the user is currently using and should make this script portable moving forward.
#
echo -e "\nRetrieving Tormes install yml file\n"
sleep 1
#
#wget https://anaconda.org/nmquijada/tormes-1.3.0/2021.06.08.113021/download/tormes-1.3.0.yml -P ${conda_base}/envs/tormestemp/
cp -r tormes-1.3.0.yml /home/harbj019/miniconda3/envs/tormestemp
#
cat <<EOF >> ${conda_base}/envs/tormestemp/reinstall
#!/bin/bash
#
echo -e "\nRemoving existing tormes environment from Conda and cleaning unused files from the Conda environment\n"
sleep 1
#
conda remove -n ${tormesenv} --all -y
conda clean --all -y
#
echo -e "\nCreating new Tormes environment in Conda\n"
sleep 1
#
conda env create -n tormes-${tormesver} --file ${conda_base}/envs/tormestemp/tormes-${tormesver}.yml
#
sed -e '/Installing Mini/,/rm/s/^/#/' ${mytormes}-setup > ${mytormes}-setup2
#
echo -e "\nMoving Kraken database back from temp location to Tormes Conda environment\n"
sleep 1
#
mv ${conda_base}/envs/tormestemp/minikraken-DB ${tormeshome}/db/
#
chmod +x ${mytormes}-setup2
#
echo -e "\nRunning tormes-setup to install other dependencies\n"
sleep 1
#
conda run -n tormes-${tormesver} --live-stream ${mytormes}-setup2
rm -rf ${mytormes}-setup2
rm -rf ${conda_base}/envs/tormestemp
#
echo -e "\n---Reinstall of Tormes is complete --- To use Tormes type: conda activate tormes-${tormesver}\n"
EOF
chmod +x ${conda_base}/envs/tormestemp/reinstall
bash ${conda_base}/envs/tormestemp/reinstall
