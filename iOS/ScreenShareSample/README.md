### Running the sample app
You will need to go to the `ScreenShareKit` Target, serach for `Mach-O Type`, and change it to `Dynamic Library` in order to link all the Pods together.
`Static Library` is for distribution because we use `OpenTok iOS SDK` across all accelerator packs. 

### Distribution
Before you run it, you have to make sure the `Mach-O Type` is `Static Library`. 
When you have updated the framework, choose `BuildFatFramework` as a running target.
Build and Run it, the latest should be in `../OneToOneScreenShareSample/`

### Notice
If you find that `ScreenShareKitBundle.bundle` is missing, it's probably you have not built the bundle yet.
Simply choose `ScreenShareKitBundle` as running target, Build and Run it.
Then you should be good to go.

### Words of author
It's better to improve the script in the future to become full automation
