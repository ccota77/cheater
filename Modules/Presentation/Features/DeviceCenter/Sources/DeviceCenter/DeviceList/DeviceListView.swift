import SwiftUI

struct DeviceListView: View {
    @ObservedObject var viewModel: DeviceListViewModel
    
    var body: some View {
        SearchableView(
            wrappedView: DeviceListContentView(viewModel: viewModel),
            searchText: $viewModel.searchText,
            isEditing: $viewModel.isSearchActive,
            isFilteredListEmpty: viewModel.isFilteredDevicesEmpty,
            searchAssets: viewModel.searchAssets,
            emptyStateAssets: viewModel.emptyStateAssets
        )
    }
}

struct DeviceListContentView: View {
    @ObservedObject var viewModel: DeviceListViewModel
    
    var body: some View {
        List {
            if viewModel.isFiltered {
                ForEach(viewModel.filteredDevices) { deviceViewModel in
                    DeviceCenterItemView(viewModel: deviceViewModel)
                }
            } else {
                Section(header: Text(viewModel.deviceListAssets.currentDeviceTitle)) {
                    if let currentDeviceVM = viewModel.currentDevice {
                        DeviceCenterItemView(viewModel: currentDeviceVM)
                    }
                }
                
                if viewModel.otherDevices.isNotEmpty {
                    Section(header: Text(viewModel.deviceListAssets.otherDevicesTitle)) {
                        ForEach(viewModel.otherDevices) { deviceViewModel in
                            DeviceCenterItemView(viewModel: deviceViewModel)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
