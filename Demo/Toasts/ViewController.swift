//
//  ViewController.swift
//  Toasts
//
//  Created by Leo on 2026/10/28.
//

import UIKit

final class ViewController: UIViewController {
    
    private struct Example {
        let title: String
        let action: () -> Void
    }
    
    private struct ExampleSection {
        let title: String
        let examples: [Example]
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    private lazy var sections: [ExampleSection] = [
        ExampleSection(title: "基础", examples: [
            Example(title: "默认 Toast") { [weak self] in
                self?.view.showToast("保存成功")
            },
            Example(title: "顶部") { [weak self] in
                let configuration = ToastConfiguration()
                configuration.position = .top
                self?.view.showToast("顶部提示", configuration: configuration)
            },
            Example(title: "居中") { [weak self] in
                let configuration = ToastConfiguration()
                configuration.position = .center
                self?.view.showToast("居中提示", configuration: configuration)
            },
            Example(title: "带图片") { [weak self] in
                self?.view.showToast("操作成功", image: self?.successImage)
            },
            Example(title: "指定坐标") { [weak self] in
                guard let self else { return }
                let point = CGPoint(x: self.view.bounds.midX, y: 180)
                self.view.showToast("自定义坐标", at: point)
            }
        ]),
        ExampleSection(title: "样式与行为", examples: [
            Example(title: "自定义样式") { [weak self] in
                let configuration = ToastConfiguration()
                configuration.visibleDuration = 2
                configuration.style.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.92)
                configuration.style.messageColor = .white
                configuration.style.cornerRadius = 16
                configuration.style.contentInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
                configuration.style.shadow = ToastShadow(color: .systemGreen, opacity: 0.35)
                self?.view.showToast("自定义绿色样式", configuration: configuration)
            },
            Example(title: "更长文案") { [weak self] in
                self?.view.showToast("这是一条比较长的提示，用来查看多行文本和最大宽度限制是否正常。")
            },
            Example(title: "点击关闭回调") { [weak self] in
                self?.view.showToast("点我关闭") { fromTap in
                    let text = fromTap ? "用户点击关闭" : "自动消失"
                    self?.view.showToast(text)
                }
            },
            Example(title: "队列弹出 3 条") { [weak self] in
                let configuration = ToastConfiguration()
                configuration.isQueueEnabled = true
                configuration.visibleDuration = 1.2
                self?.view.showToast("第一条", configuration: configuration)
                self?.view.showToast("第二条", configuration: configuration)
                self?.view.showToast("第三条", configuration: configuration)
            }
        ]),
        ExampleSection(title: "Activity", examples: [
            Example(title: "显示 Activity") { [weak self] in
                self?.view.showActivityToast()
            },
            Example(title: "居中 Activity") { [weak self] in
                let configuration = ToastConfiguration()
                configuration.position = .center
                self?.view.showActivityToast(configuration: configuration)
            },
            Example(title: "2 秒后关闭 Activity") { [weak self] in
                self?.view.showActivityToast()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.view.hideActivityToast()
                    self?.view.showToast("加载完成")
                }
            },
            Example(title: "隐藏 Activity") { [weak self] in
                self?.view.hideActivityToast()
            }
        ]),
        ExampleSection(title: "控制", examples: [
            Example(title: "隐藏当前 Toast") { [weak self] in
                self?.view.hideToast()
            },
            Example(title: "隐藏全部") { [weak self] in
                self?.view.hideAllToasts()
            }
        ])
    ]
    
    private var successImage: UIImage? {
        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        return UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?
            .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Toasts Demo"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].examples.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].examples[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].examples[indexPath.row].action()
    }
}
