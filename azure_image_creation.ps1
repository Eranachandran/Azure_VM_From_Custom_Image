################################################################################################################################################
# Script Name: azure_image_creation.ps1
# Author: Eranachandran
# Date : 05-01-2020
# Description: The following powershell script will create a custom azure image from a managed disk
# script usage: ./azure_image_creation.ps1 -resourceGroupName <resourceGroupName> -location <location> -vmName <vmName> -snapshotName <snapshotName> -imageName <imageName>
################################################################################################################################################

##############Required Inputs for this Script starts #################

param(
   [string] $resourceGroupName,
   [string] $location,
   [string] $vmName,
   [string] $snapshotName,
   [string] $imageName
)

##############Required Inputs for this Script ends #################

############ Snapshot Creation Starts ######################

#Get the VM
$vm = get-azvm -ResourceGroupName $resourceGroupName -Name $vmName


#Create the snapshot configuration
$snapshot =  New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy

#Take the snapshot
New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName

############ Snapshot Creation ends ######################


############### Managed Image Creation Starts #######################

#Get the snapshot
$snapshot = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName

#Create the image configuration
$imageConfig = New-AzImageConfig -Location $location
$imageConfig = Set-AzImageOsDisk -Image $imageConfig -OsState Generalized -OsType linux -SnapshotId $snapshot.Id

#Create the image
New-AzImage -ImageName $imageName -ResourceGroupName $resourceGroupName -Image $imageConfig

############### Managed Image Creation ends #######################
