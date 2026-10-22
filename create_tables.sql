-- Лабораторная работа №1. PostgreSQL. Вариант 22.
-- Две таблицы: отделы и графики работы.
-- Используйте только в пустой базе данных; при существующих таблицах не запускать повторно.

CREATE TABLE public.departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    serves_individuals BOOLEAN NOT NULL DEFAULT FALSE,
    serves_legal_entities BOOLEAN NOT NULL DEFAULT FALSE,
    department_functions TEXT NOT NULL,
    CONSTRAINT uq_departments_name UNIQUE (name),
    CONSTRAINT chk_departments_name_not_blank CHECK (BTRIM(name) <> ''),
    CONSTRAINT chk_departments_functions_not_blank CHECK (BTRIM(department_functions) <> '')
);

COMMENT ON TABLE public.departments IS 'Вариант 22: отделы почтовой организации';
COMMENT ON COLUMN public.departments.department_id IS 'Код отдела, автоинкремент';
COMMENT ON COLUMN public.departments.name IS 'Название отдела';
COMMENT ON COLUMN public.departments.serves_individuals IS 'Обслуживание физических лиц';
COMMENT ON COLUMN public.departments.serves_legal_entities IS 'Обслуживание юридических лиц';
COMMENT ON COLUMN public.departments.department_functions IS 'Функции отдела';

CREATE TABLE public.work_schedules (
    post_office_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    weekday VARCHAR(15) NOT NULL,
    work_start TIME NOT NULL,
    work_end TIME NOT NULL,
    break_start TIME NULL,
    break_end TIME NULL,
    CONSTRAINT pk_work_schedules PRIMARY KEY (post_office_id, department_id, weekday),
    CONSTRAINT fk_work_schedules_departments FOREIGN KEY (department_id)
      REFERENCES public.departments (department_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_post_office_positive CHECK (post_office_id > 0),
    CONSTRAINT chk_weekday CHECK (weekday IN ('Понедельник', 'Вторник', 'Среда',
      'Четверг', 'Пятница', 'Суббота', 'Воскресенье')),
    CONSTRAINT chk_work_interval CHECK (work_start < work_end),
    CONSTRAINT chk_break_both_or_none CHECK
      ((break_start IS NULL AND break_end IS NULL)
      OR (break_start IS NOT NULL AND break_end IS NOT NULL)),
    CONSTRAINT chk_break_inside_work CHECK
      (break_start IS NULL OR
       (work_start < break_start AND break_start < break_end AND break_end < work_end))
);

CREATE INDEX idx_work_schedules_department_id
    ON public.work_schedules (department_id);

COMMENT ON TABLE public.work_schedules IS 'Вариант 22: графики работы отделов в почтовых отделениях';
COMMENT ON COLUMN public.work_schedules.post_office_id IS 'Код почтового отделения; таблица отделений не входит в вариант 22';
COMMENT ON COLUMN public.work_schedules.department_id IS 'Код отдела (внешний ключ)';
COMMENT ON COLUMN public.work_schedules.weekday IS 'День недели';
COMMENT ON COLUMN public.work_schedules.work_start IS 'Время начала работы';
COMMENT ON COLUMN public.work_schedules.work_end IS 'Время окончания работы';
COMMENT ON COLUMN public.work_schedules.break_start IS 'Время начала перерыва, может быть NULL';
COMMENT ON COLUMN public.work_schedules.break_end IS 'Время окончания перерыва, может быть NULL';
