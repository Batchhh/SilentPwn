#pragma once

namespace IL2CPP
{
	namespace Image
	{
		Unity::il2cppImage* GetByName(const char *image)
		{
			// Retrieve the assemblies in the current domain
			size_t assemblyCount = 0;
			Unity::il2cppAssembly **assemblies = Domain::GetAssemblies(&assemblyCount);

			// Iterate over each assembly
			for (size_t i = 0; i < assemblyCount; ++i)
			{
				// Get the image from the current assembly
				void *img = reinterpret_cast<void*(IL2CPP_CALLING_CONVENTION)(Unity::il2cppAssembly *)>(Functions.m_AssembliesGetImage)(assemblies[i]);

				// Get the image name
				const char *imgName = reinterpret_cast<const char*(IL2CPP_CALLING_CONVENTION)(void *)>(Functions.m_ImageGetName)(img);

				// Compare the image name with the one we are looking for
				if (strcmp(imgName, image) == 0)
				{
					return reinterpret_cast<Unity::il2cppImage*>(img); // Return the image cast to il2cppImage*
				}
			}

			// If no match is found, return nullptr
			return nullptr;
		}
	}
}